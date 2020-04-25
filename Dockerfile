FROM node:10

WORKDIR /usr/src/app

RUN \
  apt-get update \
  && apt-get -y install cron curl tar awscli \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN touch /var/log/cron.log db.json
COPY package.json ./
RUN npm install
COPY ./app .

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
