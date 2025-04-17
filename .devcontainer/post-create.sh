#!/bin/bash

if [ -n "$CODESPACE_NAME" ]; then
  echo "Set the ASSET_HOST envar with the Codespace host..."
  ASSET_HOST="https://$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^ASSET_HOST=' ./.env; then
    sed -i "s|^ASSET_HOST=.*|ASSET_HOST=$ASSET_HOST|" ./.env
  else
    echo "ASSET_HOST=$ASSET_HOST" >> ./.env
  fi

  echo "Set the DOMAIN envar with the Codespace domain..."
  DOMAIN="$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^DOMAIN=' ./.env; then
    sed -i "s|^DOMAIN=.*|DOMAIN=$DOMAIN|" ./.env
  else
    echo "DOMAIN=$DOMAIN" >> ./.env
  fi

  echo "Set the PROTOCOL envar with the Codespace protocol..."
  PROTOCOL="https"
  if grep -q '^PROTOCOL=' ./.env; then
    sed -i "s|^PROTOCOL=.*|PROTOCOL=$PROTOCOL|" ./.env
  else
    echo "PROTOCOL=$PROTOCOL" >> ./.env
  fi
fi
