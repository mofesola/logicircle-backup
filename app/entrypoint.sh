#!/usr/bin/env bash

echo "Syncing files to ${S3_BUCKET}"
touch cronfile
printenv | sed 's/^\(.*\)$/export \1/g' > /root/project_env.sh
chmod +x /root/project_env.sh
echo "* * * * * /usr/src/app/backup.sh >> /var/log/cron.log 2>&1" >> cronfile
crontab cronfile
service cron restart
tail -f /var/log/cron.log
/bin/bash
