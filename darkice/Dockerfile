FROM alpine:latest
LABEL org.opencontainers.image.title="DarkIce" \
      org.opencontainers.image.authors="Cédrik LIME"

# alsa-utils
RUN apk add --no-cache darkice \
  && mv /etc/darkice/darkice.cfg /etc/darkice/darkice.cfg.sample

USER nobody:audio

CMD ["darkice", "-c", "/etc/darkice.cfg"]
