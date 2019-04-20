#FROM alpine:latest
FROM docker:stable
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY launch-httpd-rewritemap-update /usr/local/bin/

RUN apk add --no-cache --virtual .run-deps curl logrotate \
	&& chmod +x /usr/local/bin/launch-httpd-rewritemap-update \
	&& crontab -l | { cat; echo "*/5  *  *  *  * /usr/local/bin/launch-httpd-rewritemap-update > /dev/null 2>&1"; } | crontab -

HEALTHCHECK --interval=60s --timeout=3s --start-period=5s --retries=3 \
	CMD pgrep -x crond || exit 1

#VOLUME ["/etc/crontabs", "/usr/local/etc/"]

CMD [ "crond", "-f", "-d", "8" ]
