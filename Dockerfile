# Stage 1: Build dependencies
FROM php:8.3-apache AS build

# Install dependencies for Yii2
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && apt-get clean

# Stage 2: Final production image
FROM php:8.3-apache

# Copy only the necessary dependencies from the build stage
COPY --from=build /usr/local/lib/php/extensions/no-debug-non-zts-*/gd.so /usr/local/lib/php/extensions/no-debug-non-zts-*/
COPY --from=build /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=build /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/x86_64-linux-gnu/

# Enable apache mod_rewrite
RUN a2enmod rewrite
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Copy the Yii2 application files
COPY . .

# Set file permissions for Yii2
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80
