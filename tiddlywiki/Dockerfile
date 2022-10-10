FROM node:lts-alpine
LABEL org.opencontainers.image.title="TiddlyWiki" \
      org.opencontainers.image.authors="Cédrik LIME"

COPY docker-entrypoint.sh  /usr/local/bin/

# To compile and install native addons from npm you may also need to install build tools: build-essential
RUN apk add --no-cache curl \
   && chown -R node: /srv

USER node

# Node.js default log level: warn
#ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_ENV=production \
    NPM_CONFIG_PREFIX=/home/node/.npm-global \
    PATH=$PATH:/home/node/.npm-global/bin \
    npm_config_send_metrics=false

RUN npm_config_update_notifier="false"  npm install --location=global --omit=dev --no-fund tiddlywiki \
  # To update: npm update --location=global tiddlywiki
  && tiddlywiki --version
#  && cd /srv \
#  && tiddlywiki wiki --init server

#VOLUME ["/srv"]

EXPOSE 8080

WORKDIR /srv

HEALTHCHECK --interval=5m --timeout=10s --start-period=5s --retries=2 \
	CMD curl -fsS -o /dev/null http://localhost:8080 || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["tiddlywiki"]
