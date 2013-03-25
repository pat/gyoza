class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_for_session

  private

  def check_for_session
    return unless session[:omniauth].nil?

    session[:redirect_to] = request.path
    redirect_to '/auth/github'
  end
end
