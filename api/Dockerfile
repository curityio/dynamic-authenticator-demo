FROM node:lts-alpine
MAINTAINER michal@curity.io

WORKDIR /usr/srv/app

COPY --chown=node:node package*.json ./
RUN npm i

COPY --chown=node:node . .
USER node

CMD ["node", "index.js"]
