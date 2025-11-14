#!/bin/sh

set -e

# Install latest ruby dependencies
bundle install

# Run commands from dockerfile
"${@}"
