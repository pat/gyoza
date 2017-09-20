require 'open-uri'

class SitesController < ApplicationController
  expose(:contents) { params[:contents] || open(github_uri).read }
  expose(:email)    { params[:email] || session[:omniauth]['info']['email'] }

  before_action :check_for_session

  def update
    Gyoza::Workers::ChangeWorker.perform_async(
      author:      author,
      user:        params[:user],
      repo:        params[:repo],
      file:        params[:path],
      contents:    contents.gsub(/\r\n?/, "\n"),
      subject:     params[:subject],
      description: params[:description],
      nickname:    session[:omniauth]['info']['nickname']
    )

    redirect_back(
      fallback_location: site_show_path(params[:user], params[:repo], params[:path]),
      notice: 'Your change will be logged as a pull request momentarily. Thank you for contributing!'
    )
  end

  private

  def author
    name = session[:omniauth]['info']['name'] ||
      session[:omniauth]['info']['nickname']

    "#{name} <#{email}>"
  end

  def github_uri
    "#{Gyoza::GITHUB_HOST}/#{params[:user]}/#{params[:repo]}/raw/gh-pages/#{params[:path]}"
  end
end
