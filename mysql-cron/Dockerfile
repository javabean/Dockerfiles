#FROM alpine:latest
FROM docker:23.0
LABEL org.opencontainers.image.authors="Cédrik LIME"

RUN apk add --no-cache --virtual .run-deps curl logrotate dash \
	&& touch /var/log/messages
#	&& crontab -l | { cat; echo "*/5  *  *  *  * /usr/local/bin/launch-something > /dev/null 2>&1"; } | crontab -

# The following MySQL|MariaDB utilities need 96 MB disk
#RUN apk add --no-cache --virtual .run-deps-mysql perl perl-doc mysql-client mariadb-server-utils mysql-bench \
## MySQLTuner
#	&& curl -fsSL https://github.com/major/MySQLTuner-perl/archive/master.tar.gz | tar xz -C /usr/local/bin/ --strip-components=1 MySQLTuner-perl-master/mysqltuner.pl MySQLTuner-perl-master/basic_passwords.txt MySQLTuner-perl-master/vulnerabilities.csv \
#	&& chmod +x /usr/local/bin/mysqltuner.pl

COPY mysql-dump.sh hc-ping.sh  /usr/local/bin/
COPY logrotate-mysql-dump /etc/logrotate.d/mysql-dump
#RUN touch /srv/dump.sql.gz

HEALTHCHECK --interval=60s --timeout=3s --start-period=5s --retries=3 \
	CMD pgrep -x crond && /usr/local/bin/hc-ping.sh -u "${DOCKER_HC_PING_URL:-}" || exit 1

#VOLUME ["/etc/crontabs", "/usr/local/etc/", "/srv"]

CMD [ "crond", "-f", "-d", "8" ]
