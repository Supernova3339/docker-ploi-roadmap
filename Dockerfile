FROM webdevops/php-nginx:8.1-alpine

ENV ROADMAPVERSION=1.35

# Install Laravel framework system requirements (https://laravel.com/docs/8.x/deployment#optimizing-configuration-loading)
RUN apk add oniguruma-dev postgresql-dev libxml2-dev
RUN docker-php-ext-install \
        ctype \
        fileinfo \
        mbstring \
        xml

# Copy Composer binary from the Composer official Docker image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV WEB_DOCUMENT_ROOT /app/public

RUN wget -O https://github.com/ploi-deploy/roadmap/archive/refs/tags/${ROADMAPVERSION}.zip \
    && unzip roadmap-${ROADMAPVERSION}.zip -d /app \
    && chmod +x /app

ENV APP_ENV production
WORKDIR /app

RUN composer install --no-interaction --optimize-autoloader --no-dev
# Optimizing Configuration loading
RUN php artisan config:cache
# Optimizing Route loading
RUN php artisan route:cache
# Optimizing View loading
RUN php artisan view:cache

RUN chown -R application:application .
