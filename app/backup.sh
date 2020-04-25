#!/usr/bin/env bash

#set -ex
source /root/project_env.sh

ROOT="/usr/src/app"
DATE=`date +%Y-%m-%d`
MONTH=`date +%m`
YEAR=`date +%Y`

cd ${ROOT}
echo "Backing up footage from ${ROOT}/${DATE}.tar.gz to s3://$S3_BUCKET/${YEAR}/${MONTH}"

cat ${ROOT}/db.json >> ${ROOT}/db.old.json
rm -f ${ROOT}/db.json

mkdir -p ${ROOT}/Downloads
echo "Downloading footage..." && node ${ROOT}/downloader.js >> /var/log/cron.log

mv  ${ROOT}/Downloads ${ROOT}/${DATE}
tar -cvf ${DATE}.tar.gz -C ${ROOT}/${DATE} .
rm -rf ${ROOT}/${DATE}

#Send to S3
aws s3 cp ${ROOT}/${DATE}.tar.gz s3://${S3_BUCKET}/${YEAR}/${MONTH} --storage-class STANDARD_IA

mkdir -p ${ROOT}/Downloads
rm -rf ${ROOT}/${DATE}.tar.gz
