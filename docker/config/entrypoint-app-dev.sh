#!/bin/bash
set -e

# Ensure there is a local .env file
if [ ! -f ".env" ]; then
  cp example.env .env
  echo "No .env file detected! The example.env file has been copied to .env."
fi

# Prevent "server is already running" errors
rm -f /var/www/catima/tmp/pids/server.pid

# Run the catima setup script
bin/setup

# Generate API doc
rails swag:run

# Run commands from dockerfile
"${@}"
