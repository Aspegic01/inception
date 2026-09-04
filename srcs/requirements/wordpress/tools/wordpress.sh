#!/bin/bash

WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD:-$(cat /run/secrets/wp_admin_password 2>/dev/null || true)}"
WP_REGULAR_PASSWORD="${WP_REGULAR_PASSWORD:-$(cat /run/secrets/wp_regular_password 2>/dev/null || true)}"
DB_PASSWORD="${DB_PASSWORD:-$(cat /run/secrets/db_password 2>/dev/null || true)}"

cd /var/www/wordpress

#download the wp-cli
if [ ! -f "/usr/local/bin/wp" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

#block execution until the MariaDB socket is fully accepting TCP connections
until mariadb -h mariadb_1 -u ${DB_USER} -p${DB_PASSWORD} -e "SELECT 1;" > /dev/null 2>&1; do
    echo "waiting for MariaDB to initialize and open port 3306..."
    sleep 2
done

#check for config file
if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create \
        --dbname=${DATA_BASE} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb_1 \
        --allow-root

    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create \
        ${WP_REGULAR_USER} \
        ${WP_REGULAR_EMAIL} \
        --role=author \
        --user_pass=${WP_REGULAR_PASSWORD} \
        --allow-root
fi

#ensure correct permissions for nginx to read the populated files
chown -R www-data:www-data /var/www/wordpress

exec php-fpm8.4 -F
