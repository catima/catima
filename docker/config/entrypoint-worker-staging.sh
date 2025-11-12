#!/bin/sh

set -e

# ensure tmp directory exists for supervisor socket
mkdir -p /var/www/catima/tmp

# run commands from dockerfile
"${@}"
