module ApplicationHelper
  def extension
    @extension ||= case params[:path][/[^\.]+$/]
    when 'md'
      'markdown'
    else
      params[:path][/[^\.]+$/]
    end
  end

  def link_to_file
    uri = [Gyoza::GITHUB_HOST, params[:user], params[:repo], 'blob',
      'gh-pages', params[:path]].join('/')
    link_to "#{params[:path]}", uri
  end

  def link_to_repo
    link_to "#{params[:user]}/#{params[:repo]}",
      "#{Gyoza::GITHUB_HOST}/#{params[:user]}/#{params[:repo]}"
  end

  def link_to_username
    username = session[:omniauth]['info']['nickname']

    link_to username, "#{Gyoza::GITHUB_HOST}/#{username}"
  end
end
