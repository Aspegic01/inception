#!/bin/bash
set -e

# Read passwords from Docker secrets if available
if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/db_root_password ]; then
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
else
    DB_ROOT_PASSWORD="${DB_PASSWORD}"
fi

# Ensure runtime directories exist with proper ownership
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialize MariaDB data directory if empty or system table is missing
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB system tables..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

# Configure database and users if our target database doesn't exist yet
if [ ! -d "/var/lib/mysql/${DATA_BASE}" ]; then
    echo "Bootstrapping database '${DATA_BASE}' and user '${DB_USER}'..."

    mariadbd --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${DB_ROOT_PASSWORD}');

CREATE DATABASE IF NOT EXISTS \`${DATA_BASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DATA_BASE}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Database bootstrap completed successfully."
fi

echo "Starting MariaDB daemon as PID 1..."
exec mariadbd --user=mysql
