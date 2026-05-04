# ========================
# Stage 1: Build
# ========================
FROM composer:2 AS builder

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader

# ========================
# Stage 2: Runtime
# ========================
FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# install composer (copy dari builder)
COPY --from=builder /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY --from=builder /app /var/www

# permission Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

USER www-data

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
