#!/bin/sh

set -e

# prevent "server is already running" errors
rm -f /var/www/catima/tmp/pids/server.pid

# run database migrations
rails db:migrate

# run commands from dockerfile
"${@}"
