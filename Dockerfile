# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
# php version arg/envvar inherited from alpine-php
# ARG PHPMAJMIN
# ENV \
#     PHPMAJMIN=${PHPMAJMIN}
#
ARG VERSION
ARG BSVERSION
#
ENV \
    KANBOARD_SRC=/opt/kanboard/kanboard-${VERSION}.zip \
    PLUGIN_BEANSTALK_SRC=/opt/kanboard/kanboard-plugin-beanstalk-${BSVERSION}.zip
    # KANBOARD_VERSION=${VERSION}
    # KANBOARD_PLUGIN_BEANSTALK_VERSION=${BSVERSION}
#
RUN set -xe \
    && apk add --no-cache --purge -Uu \
        beanstalkd \
        ca-certificates \
        curl \
        mailx \
        openssl \
        sqlite \
        ssmtp \
        tzdata \
        zip \
        unzip \
#
        php${PHPMAJMIN}-bcmath \
        php${PHPMAJMIN}-ctype \
        php${PHPMAJMIN}-curl \
        php${PHPMAJMIN}-dom \
        php${PHPMAJMIN}-fpm \
        php${PHPMAJMIN}-gd \
        php${PHPMAJMIN}-iconv \
        php${PHPMAJMIN}-json \
        php${PHPMAJMIN}-ldap \
        php${PHPMAJMIN}-mbstring \
        php${PHPMAJMIN}-opcache \
        php${PHPMAJMIN}-openssl \
        php${PHPMAJMIN}-pdo \
        php${PHPMAJMIN}-pdo_mysql \
        php${PHPMAJMIN}-pdo_pgsql \
        php${PHPMAJMIN}-pdo_sqlite \
        php${PHPMAJMIN}-phar \
        php${PHPMAJMIN}-posix \
        php${PHPMAJMIN}-session \
        php${PHPMAJMIN}-simplexml \
        php${PHPMAJMIN}-sockets \
        php${PHPMAJMIN}-xml \
        php${PHPMAJMIN}-zip \
        php${PHPMAJMIN}-zlib \
#
        php${PHPMAJMIN}-intl \
        # php${PHPMAJMIN}-mcrypt \
        php${PHPMAJMIN}-mysqli \
        php${PHPMAJMIN}-mysqlnd \
        php${PHPMAJMIN}-pgsql \
        php${PHPMAJMIN}-sqlite3 \
#
    && mkdir -p \
        /defaults \
        /opt/kanboard \
    && if [ -f "/etc/php${PHPMAJMIN}/php.ini" ]; then mv /etc/php${PHPMAJMIN}/php.ini /defaults/php.ini; fi \
    && if [ -f "/etc/php${PHPMAJMIN}/php-fpm.conf" ]; then mv /etc/php${PHPMAJMIN}/php-fpm.conf /defaults/php-fpm.conf; fi \
    && if [ -f "/etc/php${PHPMAJMIN}/php-fpm.d/www.conf" ]; then mv /etc/php${PHPMAJMIN}/php-fpm.d/www.conf /defaults/php-fpm-www.conf; fi \
#
    && echo "${VERSION}" > /opt/kanboard/version \
    && curl \
        -o ${KANBOARD_SRC} \
        -jSLN "https://github.com/kanboard/kanboard/archive/refs/tags/v${VERSION}.zip" \
#
    && echo "${BSVERSION}" > /opt/kanboard/plugin_beanstalk_version \
    && curl \
        -o ${PLUGIN_BEANSTALK_SRC} \
        -jSLN "https://github.com/kanboard/plugin-beanstalk/releases/download/v${BSVERSION}/Beanstalk-${BSVERSION}.zip" \
#
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
# ${WEBDIR} from alpine-nginx/alpine-php (default: /config/www)
VOLUME /config/www/kanboard/data/ /config/www/kanboard/plugins/
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:80/kanboard/"} || exit 1
#
# ports, entrypoint etc from nginx
# ENTRYPOINT ["/init"]
