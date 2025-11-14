#!/bin/sh

set -e

# Ensure tmp directory exists for supervisor socket
mkdir -p /var/www/catima/tmp

# Run commands from dockerfile
"${@}"
