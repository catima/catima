#!/bin/sh

set -e

# prevent "server is already running" errors
rm -f /var/www/catima/tmp/pids/server.pid

# run the catima setup script
bin/setup

# generate API doc
rails swag:run

# run commands from dockerfile
"${@}"
