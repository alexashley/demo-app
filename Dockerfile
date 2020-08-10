FROM node:14.7.0-alpine3.10

EXPOSE 1234
WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .
RUN yarn install
COPY index.spec.js .
COPY index.js .

ENTRYPOINT ["yarn", "start"]