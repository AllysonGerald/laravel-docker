FROM php:8.4-fpm

WORKDIR /var/www

RUN rm -rf /var/www/html

# Install system dependencies and PHP extensions in a single layer
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev \
    apt-utils \
    libonig-dev \
    libicu-dev \
    ca-certificates \
    && apt-get upgrade -y \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install zip pdo_mysql mbstring exif intl gd fileinfo bcmath \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*

# Install Composer with checksum verification (latest checksum)
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && curl -sS https://composer.github.io/installer.sig -o composer-setup.php.sig \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === trim(file_get_contents('composer-setup.php.sig'))) { echo 'Installer verified' . PHP_EOL; } else { echo 'Installer corrupt' . PHP_EOL; unlink('composer-setup.php'); exit(1); }" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php composer-setup.php.sig

# Configure PHP security settings
RUN echo "expose_php = Off" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "allow_url_fopen = Off" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "allow_url_include = Off" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "session.cookie_httponly = On" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "session.cookie_secure = On" >> /usr/local/etc/php/conf.d/security.ini \
    && echo "session.use_strict_mode = On" >> /usr/local/etc/php/conf.d/security.ini

# Create user and group with specific IDs
RUN groupadd -g 1000 developer \
    && useradd -u 1000 -ms /bin/bash -g developer user

# Copy application files with proper ownership
COPY --chown=user:developer . /var/www

# Switch to non-root user for security
USER user

EXPOSE 9000

CMD ["php-fpm"]
