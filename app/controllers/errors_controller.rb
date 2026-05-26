class ErrorsController < ApplicationController
  def show
    error_id = params[:id].to_s
    if lookup_context.exists?(error_id, "errors")
      render "errors/#{error_id}", status: :ok
    else
      render "errors/900", status: :not_found
    end
  end
end
