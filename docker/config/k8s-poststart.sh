#!/bin/bash

if [ "$(pwd)" != "/var/www/catima" ]; then
  cd /var/www/impact || { echo "Failed to change directory to /var/www/catima"; exit 1; }
fi

# Notify BugSnag about the deployment
rake bugsnag:deploy \
  BUILDER="Deployer"
