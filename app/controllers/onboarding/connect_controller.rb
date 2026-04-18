module Onboarding
  class ConnectController < BaseController
    def show
    end

    def start
      if profile.stripe_connect_id.blank?
        account = Stripe::Account.create({
          type: "express",
          metadata: { user_id: current_user.id }
        })
        profile.update!(stripe_connect_id: account.id)
      end

      account_link = Stripe::AccountLink.create({
        account: profile.stripe_connect_id,
        refresh_url: "#{ENV["APP_HOST"]}#{onboarding_connect_refresh_path}",
        return_url:  "#{ENV["APP_HOST"]}#{onboarding_connect_refresh_path}",
        type: "account_onboarding"
      })

      redirect_to account_link.url, allow_other_host: true
    end

    def refresh
      if profile.stripe_connect_id.present?
        account = Stripe::Account.retrieve(profile.stripe_connect_id)

        if account.charges_enabled && account.details_submitted
          profile.update!(
            connect_onboarding_status: "active",
            onboarding_step: 4
          )
          flash[:notice] = "Stripe Connect setup complete!"
          redirect_to onboarding_complete_path
        else
          flash[:alert] = "Stripe setup incomplete. Please finish the form."
          redirect_to onboarding_connect_path
        end
      else
        redirect_to onboarding_connect_path
      end
    end
  end
end