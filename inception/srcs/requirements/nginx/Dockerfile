FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y nginx \
	&& apt-get install -y openssl

COPY ./conf/default /etc/nginx/sites-enabled

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]
