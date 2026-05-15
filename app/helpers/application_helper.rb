module ApplicationHelper
  def compute_plain_email_hash(email)
    require 'openssl'
    secret = Rails.application.credentials.dig(:plain, :secret) || ENV['PLAIN_CHAT_SECRET']
    return nil unless secret.present?
    OpenSSL::HMAC.hexdigest('sha256', secret, email)
  end
end
