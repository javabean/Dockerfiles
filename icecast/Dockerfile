FROM alpine:latest
LABEL org.opencontainers.image.title="Icecast" \
      org.opencontainers.image.authors="Cédrik LIME"

RUN apk add --no-cache icecast mailcap

WORKDIR /usr/share/icecast

#VOLUME ["/var/log/icecast"]

EXPOSE 8000 8001 8080 8443

USER icecast

CMD ["icecast", "-c", "/etc/icecast.xml"]
