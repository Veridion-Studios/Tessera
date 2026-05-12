class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :about, :join]

  def home
  end

  def join
  end

  def about
  end
end