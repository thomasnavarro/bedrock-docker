FROM php:8.0-fpm as base
LABEL name=wordpress
LABEL intermediate=true

# Install essential packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends  \
    build-essential \
    curl \
    git \
    gnupg \
    zip \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

FROM base as php
LABEL name=wordpress
LABEL intermediate=true

# Install the PHP extensions
# (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN set -ex && \
	chmod +x /usr/local/bin/install-php-extensions && sync \
	&& install-php-extensions \
		curl \
		exif \
		imagick \
		mbstring \
		openssl \
		zip \
		memcached \
		bcmath \
		gd \
		intl \
		zlib \
		ssh2 \
		ftp \
		sockets \
		mysqli \
		pcntl \
		pdo_mysql \
	&& apt-get update \
	&& apt-get install -y \
		gifsicle \
		jpegoptim \
		libpng-dev \
		libjpeg62-turbo-dev \
		libfreetype6-dev \
		libmemcached-dev \
		locales \
		lua-zlib-dev \
		optipng \
		pngquant \
		ghostscript \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# Set recommended PHP.ini settings
# (https://secure.php.net/manual/en/opcache.installation.php)
RUN set -eux; \
	docker-php-ext-enable opcache; \
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Configure error logging
# (https://www.php.net/manual/en/errorfunc.constants.php)
# (https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670)
RUN { \
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /usr/local/etc/php/conf.d/error-logging.ini

FROM php as wordpress
LABEL name=wordpress

# Install Node and PNPM
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash \
  && apt-get update \
  && apt-get install -y \
    nodejs \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && npm install -g pnpm

# WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/bin/_wp;
COPY ./build/bin/wp.sh /srv/wp.sh
RUN chmod +x /srv/wp.sh \
  && mv /srv/wp.sh /usr/bin/wp

COPY ./build/bin/wordpress-install.sh /srv/wordpress-install.sh
RUN chmod +x /srv/wordpress-install.sh

VOLUME /var/www/html

# Note : Utilisez `docker compose up -d --force-recreate --build` si vous modifiez le Dockerfile.
