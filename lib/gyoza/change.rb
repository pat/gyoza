require 'tmpdir'
require 'tempfile'
require 'fileutils'

class Gyoza::Change
  def initialize(options)
    @options = options.symbolize_keys
  end

  def change
    fork
    clone
    update_fork
    patch
    pull_request
  ensure
    Dir.chdir '/'

    FileUtils.remove_entry tmp_directory
  end

  private

  attr_reader :options

  def branch
    @branch ||= "patch-#{Time.zone.now.to_i}"
  end

  def clone
    shell.run "git clone --branch gh-pages https://#{Gyoza::GITHUB_USERNAME}@github.com/#{Gyoza::GITHUB_USERNAME}/#{options[:repo]} #{path}"
    Dir.chdir path
  end

  def description
    [
      options[:description],
      "Contributed by @#{options[:nickname]}"
    ].join("\n\n").strip
  end

  def fork
    begin
      gh["repos/#{Gyoza::GITHUB_USERNAME}/#{options[:repo]}"]
    rescue GH::Error
      gh.post "/repos/#{options[:user]}/#{options[:repo]}/forks", {}

      sleep 20

      gh["repos/#{Gyoza::GITHUB_USERNAME}/#{options[:repo]}"]
    end
  end

  def gh
    @gh ||= GH.tap do |gh|
      gh.current.setup Gyoza::GITHUB_API_HOST, {
        username: Gyoza::GITHUB_USERNAME, password: Gyoza::GITHUB_PASSWORD
      }
    end
  end

  def patch
    shell.run "git checkout -b #{branch}"

    File.open(File.join(path, options[:file]), 'w') { |file|
      file.print options[:contents]
    }

    shell.run(
      "git add #{options[:file]}",
      "git commit --message=\"#{options[:subject]}\" --author=\"#{options[:author]}\"",
      "git push origin #{branch}"
    )
  end

  def path
    @path ||= File.join tmp_directory, options[:repo]
  end

  def pull_request
    gh.post "repos/#{options[:user]}/#{options[:repo]}/pulls", {
      'title' => options[:subject],
      'body'  => description,
      'head'  => "#{Gyoza::GITHUB_USERNAME}:#{branch}",
      'base'  => 'gh-pages'
    }
  end

  def shell
    @shell ||= Gyoza::Shell.new
  end

  def tmp_directory
    @tmp_directory ||= Dir.mktmpdir
  end

  def update_fork
    shell.run(
      "git remote add #{options[:user]} git://#{Gyoza::GITHUB}/#{options[:user]}/#{options[:repo]}",
      "git fetch #{options[:user]}",
      "git merge #{options[:user]}/gh-pages",
      "git push origin gh-pages"
    )
  end
end
