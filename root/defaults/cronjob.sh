#!/usr/bin/with-contenv bash
set -e

# 0 8 * * * cd /var/www/app && php83 ./cli cronjob >/dev/null 2>&1

ROOTDIR="${ROOTDIR:-/config}";
WEBDIR="${WEBDIR:-$ROOTDIR/www}";
KANBOARDDIR="${KANBOARDDIR:-$WEBDIR/kanboard}"; # note: no ending /

cd ${KANBOARDDIR} || exit 1;

echo "[$(date -R)] Running Kanboard CRON Job...";

s6-setuidgid ${S6_USER:-alpine} \
    php ./cli cronjob \
    # >/dev/stdout 2>/dev/stderr
