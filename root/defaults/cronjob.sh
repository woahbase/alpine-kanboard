#!/usr/bin/with-contenv bash
set -e

# 0 8 * * * cd /var/www/app && php83 ./cli cronjob >/dev/null 2>&1

usercmd () { if [ "X${EUID}" != "X0" ]; then ${1} "${@:2}"; else s6-setuidgid ${PUID:-1000}:${PGID:-1000} ${1} "${@:2}"; fi; }

ROOTDIR="${ROOTDIR:-/config}";
WEBDIR="${WEBDIR:-$ROOTDIR/www}";
KANBOARDDIR="${KANBOARDDIR:-$WEBDIR/kanboard}"; # note: no ending /

cd ${KANBOARDDIR} || exit 1;

echo "[$(date -R)] Running Kanboard CRON Job...";

usercmd \
    php ./cli cronjob \
    # >/dev/stdout 2>/dev/stderr
