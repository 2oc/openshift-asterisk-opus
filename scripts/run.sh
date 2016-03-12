#!/bin/sh

STAMP=$(date)

echo "oc:x:`id -u`:0:oc:/:/sbin/nologin" >> /etc/passwd

# set apache as owner/group
if [ "$FIX_OWNERSHIP" != "" ]; then
	chown -R `id -u`:0 /etc/asterisk /var/log/asterisk /var/run/asterisk
fi

echo "oc:x:`id -u`:0:oc:/:/sbin/nologin" >> /etc/passwd

echo "[${STAMP}] Starting daemon..."
# run asterisk daemon
# TBD

sleep 1d;
