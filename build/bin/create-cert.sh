#!/usr/bin/env sh

set -e

source "../../.env"

DOMAIN=$(echo "$DOMAIN")

mkcert -install "localhost" "127.0.0.1" "::" "${DOMAIN}"

mkdir -p ../../certs

find . -type f -name "*.pem" -exec mv {} ../../certs \;
