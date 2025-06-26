#!/bin/bash

ENV_FILE=${1:-"./.env"}

if [ -n "$CODESPACE_NAME" ]; then
  echo "Set the ASSET_HOST envar with the Codespace host..."
  ASSET_HOST="https://$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^ASSET_HOST=' "$ENV_FILE"; then
    sed -i "s|^ASSET_HOST=.*|ASSET_HOST=$ASSET_HOST|" "$ENV_FILE"
  else
    echo "ASSET_HOST=$ASSET_HOST" >> "$ENV_FILE"
  fi

  echo "Set the DOMAIN envar with the Codespace domain..."
  DOMAIN="$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^DOMAIN=' "$ENV_FILE"; then
    sed -i "s|^DOMAIN=.*|DOMAIN=$DOMAIN|" "$ENV_FILE"
  else
    echo "DOMAIN=$DOMAIN" >> "$ENV_FILE"
  fi

  echo "Set the PROTOCOL envar with the Codespace protocol..."
  PROTOCOL="https"
  if grep -q '^PROTOCOL=' "$ENV_FILE"; then
    sed -i "s|^PROTOCOL=.*|PROTOCOL=$PROTOCOL|" "$ENV_FILE"
  else
    echo "PROTOCOL=$PROTOCOL" >> "$ENV_FILE"
  fi
fi
