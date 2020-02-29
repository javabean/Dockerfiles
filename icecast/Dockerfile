FROM alpine:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

RUN apk add --no-cache icecast mailcap

WORKDIR /usr/share/icecast

#VOLUME ["/var/log/icecast"]

EXPOSE 8000 8001 8080 8443

USER icecast

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["icecast", "-c", "/etc/icecast.xml"]
