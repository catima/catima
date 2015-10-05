set :branch, ENV.fetch("CAPISTRANO_BRANCH", "development")
set :mb_sidekiq_concurrency, 1

server "v3s.naxio.ch",
       :user => "deployer",
       :roles => %w(app backup cron db redis sidekiq web)
