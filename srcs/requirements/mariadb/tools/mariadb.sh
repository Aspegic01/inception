#!/bin/bash

# 1. Grab password from secret
DB_PASSWORD=$(cat /run/secrets/db_password)

# 2. Setup socket folder
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# 3. Setup database and user

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi
# 4. Start mariadb in the background
if [ ! -d "/var/lib/mysql/$DATA_BASE" ]; then
    mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$DATA_BASE\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$DATA_BASE\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
fi
# 5. Start mariadb in the foreground
exec mariadbd --user=mysql