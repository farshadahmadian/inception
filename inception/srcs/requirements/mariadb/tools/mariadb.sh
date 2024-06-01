#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RESET='\033[0m'

VAR=$(ls /var/lib/mysql | grep -w $WP_DB)
DB_USER_PASS=$(cat /run/secrets/db_user_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

if [ "$VAR" = "$WP_DB" ]; then
	echo -e "${GREEN}The mariadb user, and the wordpress database already exists.${RESET}"
else 
	echo -e "${BLUE}Initializing mariadb user and creating the wordpress database ...${RESET}"

	echo "FLUSH PRIVILEGES;
	CREATE USER '$DB_USER'@'$WP_HOST' IDENTIFIED BY '$DB_USER_PASS';
	CREATE DATABASE $WP_DB;
	GRANT ALL PRIVILEGES ON \`$WP_DB\`.* TO '$DB_USER'@'$WP_HOST';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
	FLUSH PRIVILEGES;" > /db-init/init

	mariadbd --bootstrap < /db-init/init
	rm -rf /db-init/init

	echo -e "${GREEN}Mariadb user and wordpress database are successfully initialized.${RESET}"
fi

exec "$@"
