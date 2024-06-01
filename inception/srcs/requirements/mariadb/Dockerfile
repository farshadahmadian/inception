FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y \
	&& apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d
COPY ./tools/mariadb.sh /db-init/
COPY ./tools/healthcheck.sh /db-init/
RUN chmod +x /db-init/mariadb.sh
RUN chmod +x /db-init/healthcheck.sh

EXPOSE 3306

ENTRYPOINT [ "/db-init/./mariadb.sh" ]

CMD [ "mariadbd-safe" ]
