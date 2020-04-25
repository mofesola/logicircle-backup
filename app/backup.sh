#!/usr/bin/env bash

set -e
source /root/project_env.sh

ROOT="/usr/src/app"
DATE=`date +%Y-%m-%d`
MONTH=`date +%m`
YEAR=`date +%Y`

cd ${ROOT}
mkdir -p ${ROOT}/Downloads/Completed
echo "Backing up footage from ${ROOT}/${DATE}.tar.gz to s3://${S3_BUCKET}/${YEAR}/${MONTH}"

cat ${ROOT}/db.json >> ${ROOT}/db.old.json
echo "Downloading footage..." && node ${ROOT}/downloader.js
mkdir -p ${ROOT}/Downloads/Completed/${DATE}
mv ${ROOT}/Downloads/*.mp4 ${ROOT}/Downloads/Completed/${DATE}/
tar -cvf ${DATE}.tar.gz -C ${ROOT}/Downloads/Completed/${DATE} ${ROOT}/Downloads/Completed/
mv ${DATE}.tar.gz ${ROOT}/Downloads/Completed/ 2>/dev/null
rm -rf ${ROOT}/Downloads/Completed/${DATE}

#Send to S3
aws s3 cp ${ROOT}/Downloads/Completed/${DATE}.tar.gz s3://${S3_BUCKET}/${YEAR}/${MONTH}/${DATE}.tar.gz --storage-class STANDARD_IA
