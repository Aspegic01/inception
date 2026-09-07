#!/bin/bash

# Read passwords from secrets
DB_PASSWORD=$(cat /run/secrets/db_password 2>/dev/null)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password 2>/dev/null)
WP_REGULAR_PASSWORD=$(cat /run/secrets/wp_regular_password 2>/dev/null)

mkdir -p /var/www/wordpress /run/php
cd /var/www/wordpress

# Wait for MariaDB to accept connections
until mariadb-admin ping -h mariadb -u "$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; do
    sleep 2
done

# Install WordPress if not already present
if [ ! -f "wp-config.php" ]; then

    wp core download --allow-root

    wp config create \
     --dbname="$DATA_BASE" \
     --dbuser="$DB_USER" \
     --dbpass="$DB_PASSWORD" \
     --dbhost="mariadb:3306" \
     --allow-root


    wp core install \
    --url="https://$DOMAIN_NAME" \
    --title="Inception" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root


    wp user create \
    "$WP_REGULAR_USER" \
    "$WP_REGULAR_EMAIL" \
    --role=author \
    --user_pass="$WP_REGULAR_PASSWORD" \
    --allow-root

fi

# Set proper web root permissions and start PHP-FPM as PID 1
chown -R www-data:www-data /var/www/wordpress
exec php-fpm8.2 -F
