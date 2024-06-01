# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fahmadia <fahmadia@student.42heilbronn.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/05/22 11:03:57 by fahmadia          #+#    #+#              #
#    Updated: 2024/05/31 09:52:55 by fahmadia         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

build:
	cd ./srcs; docker compose build

up: build
	cd ./srcs; docker compose up

down:
	cd ./srcs; docker compose down

stop:
	cd ./srcs; docker compose stop

start:
	cd ./srcs; docker compose start

containersremove:
	cd ./srcs; docker rm -f nginx_container wordpress_container mariadb_container

imagesremove: containersremove
	cd ./srcs; docker rmi -f mariadb nginx wordpress

volumesremove: imagesremove
	cd ./srcs; docker volume rm -f wordpress db
	