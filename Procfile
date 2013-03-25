web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
console: bundle exec rails console
worker: bundle exec sidekiq --concurrency 5 --queue default
