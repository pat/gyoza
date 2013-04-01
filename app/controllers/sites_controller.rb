require 'open-uri'

class SitesController < ApplicationController
  expose(:contents) { params[:contents] || open(github_uri).read }

  before_filter :check_for_session

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

    redirect_to :back
  end

  private

  def author
    name = session[:omniauth]['info']['name'] ||
      session[:omniauth]['info']['nickname']

    "#{name} <#{session[:omniauth]['info']['email']}>"
  end

  def github_uri
    "#{Gyoza::GITHUB_HOST}/#{params[:user]}/#{params[:repo]}/raw/gh-pages/#{params[:path]}"
  end
end
