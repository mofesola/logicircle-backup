#!/usr/bin/env bash

set -e
source /root/project_env.sh

ROOT="/usr/src/app"
DATE=`date +%Y-%m-%d`
MONTH=`date +%m`
YEAR=`date +%Y`

cd ${ROOT}
mkdir -p ${ROOT}/Downloads/Completed
mkdir -p ${ROOT}/network_drive/${YEAR}/${MONTH}
if [[ $BACKUP_TYPE == "s3" ]]
then
  echo "Backing up footage from ${ROOT}/${DATE}.tar.gz to s3://${S3_BUCKET}/${YEAR}/${MONTH}"
elif [[ $BACKUP_TYPE == "drive" ]]
then
  echo "Backing up footage from ${ROOT}/${DATE}.tar.gz to ${ROOT}/network_drive/${YEAR}/${MONTH}"
else
  echo "Backup will be left in download folder and will be deleted in future"
fi

cat ${ROOT}/db.json >> ${ROOT}/db.old.json
echo "Downloading footage..." && node ${ROOT}/downloader.js
mkdir -p ${ROOT}/Downloads/Completed/${DATE}
mv ${ROOT}/Downloads/*.mp4 ${ROOT}/Downloads/Completed/${DATE}/ 2>/dev/null
tar --exclude='*.tar.gz' -cvf ${DATE}.tar.gz -C ${ROOT}/Downloads/Completed/${DATE} ${ROOT}/Downloads/Completed/

mv ${DATE}.tar.gz ${ROOT}/Downloads/Completed/ 2>/dev/null
rm -rf ${ROOT}/Downloads/Completed/${DATE}

#Backup
if [[ $BACKUP_TYPE == "s3" ]]
then
  aws s3 cp ${ROOT}/Downloads/Completed/${DATE}.tar.gz s3://${S3_BUCKET}/${YEAR}/${MONTH}/${DATE}.tar.gz --storage-class STANDARD_IA
elif [[ $BACKUP_TYPE == "drive" ]]
then
  cp ${ROOT}/Downloads/Completed/${DATE}.tar.gz ${ROOT}/network_drive/${YEAR}/${MONTH}/${DATE}.tar.gz
else
  echo "Backup left in download folder and will be deleted in future"
fi