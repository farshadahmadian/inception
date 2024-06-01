#!/bin/bash

if [ -e /var/lib/mysql/wpdb ]; then
	echo "Mariadb is running ..."
	exit 0
else
	echo "Mariadb is not running!"
	exit 1
fi
