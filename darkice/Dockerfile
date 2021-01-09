FROM alpine:latest
LABEL org.opencontainers.image.authors="Cédrik LIME"

# alsa-utils
RUN apk add --no-cache darkice \
  && mv /etc/darkice/darkice.cfg /etc/darkice/darkice.cfg.sample

USER nobody:audio

#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["darkice", "-c", "/etc/darkice.cfg"]
