FROM httpd:2.4
LABEL org.opencontainers.image.authors="Cédrik LIME"

############### FIXME  change URL here! ###############
ARG DISPATCHER_URL=https://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-4.3.3.tar.gz
ARG AEM_ENDPOINT=127.0.0.1
# "author" | "publish"
ARG AEM_AP_RUNMODE=

COPY . /usr/src/docker_build
RUN cd /usr/src/docker_build \
	&& if [ "$AEM_AP_RUNMODE" = "author" ]; then OPT_ARG="-a"; fi \
	&& if [ "$AEM_AP_RUNMODE" = "publish" ]; then OPT_ARG="-p"; fi \
	&& ./install-dispatcher.sh "$OPT_ARG" "$AEM_ENDPOINT" -d "$DISPATCHER_URL" \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/docker_build

HEALTHCHECK --interval=60s --timeout=10s --start-period=5s --retries=3 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

#VOLUME ["/usr/local/apache2/htdocs", "/usr/local/apache2/logs"]

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["httpd-foreground"]
