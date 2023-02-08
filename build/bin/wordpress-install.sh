#!/usr/bin/env sh

set -e

# Install WordPress
wp core install --url=$WP_HOME \
  --title=bedrock \
  --admin_user=interlude \
  --admin_email=wordpress@interludesante.com \
  --admin_password=interlude \

# Set default settings
wp language core install fr_FR
wp site switch-language fr_FR
wp rewrite structure '/%postname%/'

# Activate all plugins
wp plugin activate --all --quiet

# Auto login
wp package install aaemnnosttv/wp-cli-login-command --quiet \
  || echo 'wp-cli-login-command is already installed'
wp login install --activate --yes --skip-plugins --skip-themes --quiet
wp login as interlude
