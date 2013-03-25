module Gyoza
  GITHUB             = ENV['GITHUB_DOMAIN'] || 'github.rc'
  GITHUB_HOST        = "http://#{GITHUB}"
  GITHUB_API_HOST    = "http://api.#{GITHUB}"
  GITHUB_USERNAME    = ENV['GITHUB_USERNAME'] || 'gyozadoc'
  GITHUB_PASSWORD    = ENV['GITHUB_PASSWORD']
  GITHUB_PRIVATE_KEY = ENV['GITHUB_PRIVATE_KEY']

  module Workers
  end
end

require 'gyoza/change'
require 'gyoza/shell'
require 'gyoza/workers/change_worker'
