set :application, "viim-core"
set :repo_url, "git@bitbucket.org:catima/viim-core.git"

# Project-specific overrides go here.
# For list of variables that can be customized, see:
# https://github.com/mattbrictson/capistrano-mb/blob/master/lib/capistrano/tasks/defaults.rake

fetch(:mb_recipes) << "sidekiq"

fetch(:mb_aptitude_packages).merge!(
  "imagemagick" => :app,
  "redis-server@ppa:chris-lea/redis-server" => :redis,
  "postgis" => :db
)

set :mb_dotenv_keys, %w(
  rails_secret_key_base
  rollbar_access_token
  sidekiq_web_username
  sidekiq_web_password
  mail_smtp_address
  mail_smtp_username
  mail_smtp_password
  mail_sender
)

namespace :viim do
  # Re-index items on every deploy, just to be safe
  desc "Rebuild the search index for all item data"
  task :reindex do
    on release_roles(:all).first do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rails, "runner", "Item.reindex"
        end
      end
    end
  end

  task :enable_postgis do
    privileged_on primary(:db) do
      execute "sudo -u postgres psql -c 'CREATE EXTENSION postgis'"
    end
  end
end
after "deploy:published", "viim:reindex"
after "mb:postgresql:create_database", "viim:enable_postgis"

# Rollbar deployment notification
task :notify_rollbar do
  on release_roles(:all).first do
    with fetch(:git_environmental_variables) do
      within repo_path do
        branch = fetch(:branch)
        set :rollbar_sha, capture(:git, %Q(log #{branch} -n 1 --pretty=format:"%H"))
        set :rollbar_token, capture("grep ROLLBAR_ACCESS_TOKEN #{shared_dotenv_path} | awk '{print substr($0, 22)}'")
      end
    end

    revision = fetch(:rollbar_sha)
    local_user = ENV.fetch("USER", nil)
    rollbar_token = fetch(:rollbar_token)
    rails_env = fetch(:rails_env)
    execute "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1"
  end
end
after "deploy:log_revision", "notify_rollbar"
