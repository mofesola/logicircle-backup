FROM node:10

WORKDIR /usr/src/app

RUN \
  apt-get update \
  && apt-get -y install cron curl tar awscli \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN touch /var/log/cron.log db.json
COPY app .
RUN npm install
RUN aws configure set s3.signature_version s3v4

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
