class Gyoza::Workers::ChangeWorker
  include Sidekiq::Worker

  def perform(options)
    Gyoza::Change.new(options).change
  end
end
