#!/bin/bash
set -e

echoerr() { echo "$@" 1>&2; }

check_vars_exist() {
  var_names=("$@")

  for var_name in "${var_names[@]}"; do
    if [ -z "${!var_name}" ]; then
      echoerr "error: missing ${var_name} environment variable"
      exit 1
    fi
  done
}

# Ensure there is no local .env file
if [ -f ".env" ]; then
  mv .env .env.bak
  echoerr ".env file detected - moved to .env.bak"
  echoerr "Please update your configuration to use environment variables in the container!"
fi

# Check a number of essential variables are set
check_vars_exist \
  SECRET_KEY_BASE \
  RAILS_ENV \
  POSTGRES_DB \
  POSTGRES_HOST \
  POSTGRES_USER \
  POSTGRES_PASSWORD \
  POSTGRES_PORT

# prevent "server is already running" errors
rm -f /var/www/catima/tmp/pids/server.pid

# run database migrations
bundle exec rake db:migrate

# run commands from dockerfile
"${@}"
