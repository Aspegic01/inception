#!/bin/bash

# Read passwords from secrets
DB_PASSWORD=$(cat /run/secrets/db_password 2>/dev/null)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password 2>/dev/null || echo "$DB_PASSWORD")

# Create runtime directory for mysql socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialize database system tables if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Setup database and users on first run
if [ ! -d "/var/lib/mysql/$DATA_BASE" ]; then
    mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`$DATA_BASE\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DATA_BASE\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Start MariaDB as PID 1
exec mariadbd --user=mysql
