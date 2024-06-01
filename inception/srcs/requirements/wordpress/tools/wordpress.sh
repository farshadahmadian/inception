#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RESET='\033[0m'

DB_USER_PASS=$(cat /run/secrets/db_user_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_pass)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_pass)

if [ -e /var/www/html/wp-config.php ]; then
	echo -e "${GREEN}Wordpress config file (wp-config.php) already exists.${RESET}"
else
	echo -e "${BLUE}Creating the wordpress config file ...${RESET}"

	wp config create --dbuser=$DB_USER --dbpass=$DB_USER_PASS --dbname=$WP_DB --dbhost=$DB_HOST

	wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --skip-email

	wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASS --role=$WP_USER_ROLE

	echo -e "${GREEN}Wordpress config file (wp-config.php) successfully created.${RESET}"
fi

exec "$@"
	