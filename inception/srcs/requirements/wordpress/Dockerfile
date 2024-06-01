FROM debian:bullseye

RUN apt-get update && apt-get upgrade \
	&& apt-get install -y php \
	&& apt-get install -y php7.4-fpm \
	&& apt-get install php-mysqli \
	&& apt-get install -y curl \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d
COPY ./tools/wordpress.sh /var/www/html/wp-config-data/

RUN chown -R www-data:www-data /var/www/html \
	&& chown -R www-data:www-data /var/log \
	&& chown -R www-data:www-data /etc/php/7.4/fpm \
	&& mkdir -p /run/php \
	&& chown -R www-data:www-data /run/php/ \
	&& chmod +x /var/www/html/wp-config-data/wordpress.sh

WORKDIR /var/www/html
	
USER www-data

RUN wp core download

EXPOSE 9000

ENTRYPOINT [ "/bin/bash", "/var/www/html/wp-config-data/wordpress.sh" ]

CMD [ "php-fpm7.4", "--nodaemonize" ]
