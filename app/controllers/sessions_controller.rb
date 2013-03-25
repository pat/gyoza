class SessionsController < ApplicationController
  def create
    session[:omniauth] = request.env['omniauth.auth'].except('extra')

    redirect_to session[:redirect_to]
    session[:redirect_to] = nil
  end

  def destroy
    session[:omniauth] = nil

    redirect_to '/'
  end
end
