require "net/http"

class PagesController < ApplicationController
  layout "legal", only: [:terms, :privacy, :escrow_policy, :cookies, :acceptable_use]
  skip_before_action :authenticate_user!, only: [
    :home, :about, :join, :status,
    :terms, :privacy, :escrow_policy, :cookies, :acceptable_use
  ]

  def home; end
  def join; end
  def about; end
  def terms; end
  def privacy; end
  def escrow_policy; end
  def cookies; end
  def acceptable_use; end

  def status
    @stripe_status = fetch_stripe_status
    @db_ok         = ActiveRecord::Base.connection.active? rescue false
    @escrow_count  = Project.where(escrow_status: "funded").count rescue nil
  end

  private

  def fetch_stripe_status
    response = Net::HTTP.get_response(URI("https://status.stripe.com/api/v2/status.json"))
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue => e
    Rails.logger.warn("Stripe status fetch failed: #{e.message}")
    nil
  end
end