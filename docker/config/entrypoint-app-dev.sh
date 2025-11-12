#!/bin/bash
set -e

# Ensure there is a local .env file
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "No .env file detected! The .env.example file has been copied to .env."
fi

# prevent "server is already running" errors
rm -f /var/www/catima/tmp/pids/server.pid

# run the catima setup script
bin/setup

# generate API doc
rails swag:run

# run commands from dockerfile
"${@}"
