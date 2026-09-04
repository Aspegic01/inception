#!/bin/bash

DB_PASSWORD="${DB_PASSWORD:-$(cat /run/secrets/db_password 2>/dev/null || true)}"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/$DATA_BASE" ]; then
	service mariadb start
	sleep 2

	mariadb -e "CREATE DATABASE IF NOT EXISTS $DATA_BASE;"
	mariadb -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
	mariadb -e "GRANT ALL PRIVILEGES ON $DATA_BASE.* TO '$DB_USER'@'%';"
	mariadb -e "FLUSH PRIVILEGES;"

	service mariadb stop
fi

exec mariadbd --user=mysql
