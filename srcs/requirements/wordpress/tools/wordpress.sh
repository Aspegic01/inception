#!/bin/bash
set -e

# Read passwords from Docker secrets if available
if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_regular_password ]; then
    WP_REGULAR_PASSWORD=$(cat /run/secrets/wp_regular_password)
fi

mkdir -p /var/www/wordpress /run/php
cd /var/www/wordpress

# Wait for MariaDB service to accept connections
echo "Waiting for MariaDB service at mariadb:3306..."
until mariadb-admin ping -h mariadb -u "${DB_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "Connected to MariaDB successfully."

# Install and configure WordPress if not already configured
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root

    echo "Configuring wp-config.php..."
    wp config create \
        --dbname="${DATA_BASE}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "Installing WordPress core site..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating regular user '${WP_REGULAR_USER}'..."
    wp user create \
        "${WP_REGULAR_USER}" \
        "${WP_REGULAR_EMAIL}" \
        --role=author \
        --user_pass="${WP_REGULAR_PASSWORD}" \
        --allow-root

    echo "WordPress installation and configuration completed."
else
    echo "wp-config.php found. Synchronizing database configuration..."
    wp config set DB_NAME "${DATA_BASE}" --allow-root
    wp config set DB_USER "${DB_USER}" --allow-root
    wp config set DB_PASSWORD "${DB_PASSWORD}" --allow-root
    wp config set DB_HOST "mariadb:3306" --allow-root
fi

# Ensure proper permissions for web server and php-fpm
chown -R www-data:www-data /var/www/wordpress

echo "Starting PHP-FPM as PID 1..."
PHP_FPM_BIN=$(which php-fpm8.2 || which php-fpm8.4 || which php-fpm)
exec ${PHP_FPM_BIN} -F
