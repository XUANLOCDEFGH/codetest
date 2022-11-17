#!/usr/bin/env bash
set -e -o pipefail

ENVIRONMENT=$1
SRCDIR=$2
ENV_FILE=$3

EPHEMERAL_ARCHIVE_BUCKET=
source $ENV_FILE

DATE=$(date)

cat <<HERE

# File generated from $0
# on ${DATE}
# https://www.freedesktop.org/software/systemd/man/systemd.service.html

[Unit]
Description=Puzzle Massive backup database
After=multi-user.target

[Service]
Type=exec
User=dev
Group=dev
WorkingDirectory=$SRCDIR
HERE
if test "${ENVIRONMENT}" == 'development'; then
echo "ExecStart=${SRCDIR}bin/backup.sh -d /home/dev db-development.dump.gz"
elif test -n "${EPHEMERAL_ARCHIVE_BUCKET}"; then
echo "ExecStart=${SRCDIR}bin/backup.sh -d /home/dev -t"
else
echo "ExecStart=${SRCDIR}bin/backup.sh -d /home/dev -w"
fi
cat <<HERE

[Install]
WantedBy=multi-user.target

HERE
