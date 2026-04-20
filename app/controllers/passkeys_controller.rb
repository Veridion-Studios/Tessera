class PasskeysController < ApplicationController
  before_action :authenticate_user!, except: [:session_options, :session_create]

  # GET /account/passkeys/prompt
  def prompt
  end

  # POST /account/passkeys/options  — creation options (authenticated)
  def options
    webauthn_id = ensure_webauthn_id!

    options = WebAuthn::Credential.options_for_create(
      user: {
        id:           webauthn_id,
        name:         current_user.email,
        display_name: current_user.email
      },
      exclude: current_user.passkeys.pluck(:external_id)
    )
    session[:passkey_creation_challenge] = options.challenge
    render json: options
  end

  # POST /account/passkeys — save new passkey (authenticated)
  def create
    webauthn_credential = WebAuthn::Credential.from_create(params[:credential])

    begin
      webauthn_credential.verify(session[:passkey_creation_challenge])

      current_user.passkeys.create!(
        label:       params[:label].presence || "Passkey #{current_user.passkeys.count + 1}",
        external_id: webauthn_credential.id,
        public_key:  webauthn_credential.public_key,
        sign_count:  webauthn_credential.sign_count
      )

      session.delete(:passkey_creation_challenge)
      render json: { status: "ok" }
    rescue WebAuthn::Error => e
      Rails.logger.error "WebAuthn error: #{e.class} — #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Unexpected passkey error: #{e.class} — #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # DELETE /account/passkeys/:id
  def destroy
    passkey = current_user.passkeys.find(params[:id])

    if current_user.passkeys.count == 1 && current_user.encrypted_password.blank?
      redirect_to account_settings_path,
        alert: "You must keep at least one passkey or set a password first."
      return
    end

    passkey.destroy!
    redirect_to account_settings_path, notice: "Passkey removed."
  end

  # POST /auth/passkeys/options — authentication options (public)
  def session_options
    allow_credentials = Passkey.pluck(:external_id).filter_map do |external_id|
      normalize_credential_id(external_id)
    end.uniq

    options = WebAuthn::Credential.options_for_get(
      allow: allow_credentials
    )
    session[:passkey_authentication_challenge] = options.challenge
    render json: options
  end

  # POST /auth/passkeys — authenticate with passkey (public)
  def session_create
    begin
      webauthn_credential = WebAuthn::Credential.from_get(parsed_credential_param)

      passkey = find_passkey_for(webauthn_credential.id)

      unless passkey
        render json: { error: "This passkey doesn't look familiar." }, status: :unauthorized
        return
      end

      webauthn_credential.verify(
        session[:passkey_authentication_challenge],
        public_key:  passkey.public_key,
        sign_count:  passkey.sign_count
      )

      passkey.update!(
        sign_count:   webauthn_credential.sign_count,
        last_used_at: Time.current
      )

      session.delete(:passkey_authentication_challenge)
      sign_in passkey.user

      respond_to do |format|
        format.json { render json: { status: "ok", redirect_to: pick_dashboard_path } }
        format.any  { redirect_to pick_dashboard_path }
      end

    rescue JSON::ParserError, ArgumentError => e
      Rails.logger.warn("Passkey payload parse error: #{e.class} - #{e.message}")
      render json: { error: "Invalid passkey payload." }, status: :unprocessable_entity
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unauthorized
    end
  end

  private

  def ensure_webauthn_id!
    return current_user.webauthn_id if current_user.webauthn_id.present?

    generated_id = WebAuthn.generate_user_id
    current_user.update_column(:webauthn_id, generated_id)
    generated_id
  end

  def webauthn_origin
    request.base_url
  end

  def parsed_credential_param
    credential = params[:credential]
    credential = JSON.parse(credential) if credential.is_a?(String)
    credential = credential.to_unsafe_h if credential.respond_to?(:to_unsafe_h)

    credential
  end

  def find_passkey_for(credential_id)
    variants = passkey_id_variants(credential_id)
    Passkey.where(external_id: variants).first
  end

  def passkey_id_variants(credential_id)
    return [credential_id.to_s] if credential_id.blank?

    raw = decode_credential_id(credential_id)
    [
      credential_id.to_s,
      Base64.urlsafe_encode64(raw, padding: false),
      Base64.urlsafe_encode64(raw, padding: true),
      Base64.strict_encode64(raw),
      Base64.strict_encode64(raw).delete("=")
    ].uniq
  rescue ArgumentError
    [credential_id.to_s]
  end

  def pad_base64(str)
    padding = (4 - (str.length % 4)) % 4
    str + ("=" * padding)
  end

  def decode_credential_id(credential_id)
    Base64.urlsafe_decode64(pad_base64(credential_id.to_s.tr("+", "-").tr("/", "_")))
  end

  def normalize_credential_id(credential_id)
    Base64.urlsafe_encode64(decode_credential_id(credential_id), padding: false)
  rescue ArgumentError
    nil
  end
end