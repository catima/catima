#!/bin/bash

cp docker/example.env docker/.env

if [ -n "$CODESPACE_NAME" ]; then
  echo "Set the ASSET_HOST envar with the Codespace host..."
  ASSET_HOST="https://$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^ASSET_HOST=' docker/.env; then
    sed -i "s|^ASSET_HOST=.*|ASSET_HOST=$ASSET_HOST|" docker/.env
  else
    echo "ASSET_HOST=$ASSET_HOST" >> docker/.env
  fi

  echo "Set the DOMAIN envar with the Codespace domain..."
  DOMAIN="$CODESPACE_NAME-8383.app.github.dev"
  if grep -q '^DOMAIN=' docker/.env; then
    sed -i "s|^DOMAIN=.*|DOMAIN=$DOMAIN|" docker/.env
  else
    echo "DOMAIN=$DOMAIN" >> docker/.env
  fi

  echo "Set the PROTOCOL envar with the Codespace protocol..."
  PROTOCOL="https"
  if grep -q '^PROTOCOL=' docker/.env; then
    sed -i "s|^PROTOCOL=.*|PROTOCOL=$PROTOCOL|" docker/.env
  else
    echo "PROTOCOL=$PROTOCOL" >> docker/.env
  fi
fi
