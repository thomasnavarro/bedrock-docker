#!/usr/bin/env sh

set -e

if ! wp core is-installed; then

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

# Remove default post
wp post delete 1 --force --defer-term-counting
wp post delete 2 --force --defer-term-counting
wp post delete 3 --force --defer-term-counting

# Activate all plugins
wp plugin activate --all --quiet
fi

# Auto login
wp package install aaemnnosttv/wp-cli-login-command \
  || echo 'wp-cli-login-command is already installed'
wp login install --activate --yes --skip-plugins --skip-themes
wp login as interlude
