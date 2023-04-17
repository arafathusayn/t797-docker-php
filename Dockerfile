FROM php:7.3-fpm

RUN apt-get update && apt-get install -y default-mysql-client --no-install-recommends \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
 	&& docker-php-ext-install pdo_mysql pcntl \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd sockets

RUN apt-get update \
    && apt-get -y install \
            libmagickwand-dev \
        --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && rm -r /var/lib/apt/lists/*

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.9.1

RUN curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer; \
  php -r " \
    \$signature = '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5'; \
    \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
      unlink('/tmp/installer.php'); \
      echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
      exit(1); \
    }"; \
  php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION}; \
  composer --ansi --version --no-interaction; \
  rm -f /tmp/installer.php; \
  find /tmp -type d -exec chmod -v 1777 {} +

# Increase PHP memory limit
RUN echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;
