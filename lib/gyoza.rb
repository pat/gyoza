require 'sidekiq'
require 'gh'

module Gyoza
  GITHUB             = ENV['GITHUB_DOMAIN'] || 'github.com'
  GITHUB_HOST        = "https://#{GITHUB}"
  GITHUB_API_HOST    = "https://api.#{GITHUB}"
  GITHUB_USERNAME    = ENV['GITHUB_USERNAME'] || 'gyozadoc'
  GITHUB_PASSWORD    = ENV['GITHUB_PASSWORD']
  GITHUB_PRIVATE_KEY = ENV['GITHUB_PRIVATE_KEY']

  module Workers
  end
end

require 'gyoza/change'
require 'gyoza/shell'
require 'gyoza/workers/change_worker'
