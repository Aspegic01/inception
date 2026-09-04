FROM debian:trixie

RUN apt-get update -y && apt-get install mariadb-server mariadb-client -y

COPY ./tools/mariadb.sh /usr/local/bin/mariadb.sh
COPY ./conf/99-server.cnf /etc/mysql/mariadb.conf.d/99-server.cnf

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/mariadb.sh" ]
