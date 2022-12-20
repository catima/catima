#!/bin/sh

set -e

# install latest ruby dependencies
bundle install

# run commands from dockerfile
"${@}"
