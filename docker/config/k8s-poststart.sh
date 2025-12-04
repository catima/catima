#!/bin/bash

if [ "$(pwd)" != "/var/www/catima" ]; then
  cd /var/www/catima || { echo "Failed to change directory to /var/www/catima"; exit 1; }
fi

# Ensure mounted volumes have correct permissions
chown -R catima:catima public
chown -R catima:catima log
chown -R catima:catima exports

# Notify BugSnag about the deployment
rake bugsnag:deploy \
  BUILDER="Deployer"
