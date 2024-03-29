FROM buildpack-deps:22.04-scm as build

RUN cd /usr/src \
# ToDo: shall we use https://dev.tt-rss.org/tt-rss/ instead?
  && git clone --depth=1 https://git.tt-rss.org/fox/tt-rss.git tt-rss \
  && rm -rf /usr/src/tt-rss/.editorconfig /usr/src/tt-rss/.eslintrc.js /usr/src/tt-rss/.git /usr/src/tt-rss/.gitignore /usr/src/tt-rss/.vscode /usr/src/tt-rss/Jenkinsfile /usr/src/tt-rss/gulpfile.js /usr/src/tt-rss/phpstan.neon /usr/src/tt-rss/phpunit.xml /usr/src/tt-rss/tests \
  && cd tt-rss/plugins.local \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-af-unburn.git          af_unburn  \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-api-resize.git         api_resize_media \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-data-migration.git     data_migration \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-enclosure-fix-type.git af_enclosure_fix_type \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-favicon-unread.git     favicon_unread \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-highlightjs.git        highlightjs \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-img-placeholders.git   img_placeholders \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-mailer-smtp.git        mailer_smtp \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-names-to-tags.git      names_to_tags \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-nginx-xaccel.git       nginx_xaccel \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-no-title-counters.git  no_title_counters \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-no-url-hashes.git      no_url_hashes \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-no-video-preload.git   no_video_preload \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-pause-bg.git           pause_bg \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-perceptual-image-hash.git  af_img_phash \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-prefs-effective-config.git prefs_effective_config \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-profile-chooser.git    profile_chooser \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-proxy-http.git         proxy_http \
  && git clone --depth=1 https://github.com/joshp23/ttrss-to-wallabag-v2       wallabag_v2 \
  && git clone --depth=1 https://github.com/DigitalDJ/tinytinyrss-fever-plugin fever


#FROM php:8.0-apache
FROM cedrik/php8-apache
LABEL org.opencontainers.image.title="Tiny Tiny RSS" \
      org.opencontainers.image.authors="Cédrik LIME"

# https://tt-rss.org/wiki/InstallationNotes
# https://tt-rss.org/wiki/PhpCompatibilityNotes
# https://tt-rss.org/wiki/UpdatingFeeds
# https://git.tt-rss.org/fox/ttrss-docker-compose

#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl git \
#	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
RUN for m in "remoteip headers env dir mime expires setenvif"; do a2enmod $m; done \
  && a2dissite 000-default \
  && rm -f /var/www/html/index.html \
  && echo "newrelic.logfile=/dev/null" > ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
  && install-php-extensions pdo pdo_mysql json xml intl mbstring fileinfo curl posix gd opcache  session dom pcntl zip openssl \
  && rm -f ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && docker-php-source delete \
  && echo "memory_limit = 256M" > ${PHP_INI_DIR}/conf.d/memory-limit.ini \
# update.php requires php to be in /usr/bin/...
  && ln -s /usr/local/bin/php /usr/bin/ \
  && sed -i \
       -e 's/newrelic.appname = "PHP Application"/newrelic.appname = "Tiny Tiny RSS"/' \
       ${PHP_INI_DIR}/conf.d/newrelic.ini

# min[0-59] hour[0-23] dom[1-31] month[1-12] dow[0-7]  command
RUN echo "*/30  *  *  *  *  php /var/www/html/update.php --feeds --quiet > /dev/null 2>&1" | busybox crontab -u www-data -

COPY tt-rss.conf ${APACHE_CONFDIR}/conf-enabled/
COPY 60-init-upgrade  /usr/local/etc/init.d/
COPY consul-healthcheck.sh /usr/local/bin/
COPY --from=build --chown=www-data:www-data /usr/src/tt-rss /usr/src/tt-rss
COPY --chown=www-data:www-data themes.local/* /usr/src/tt-rss/themes.local/
