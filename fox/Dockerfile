FROM node:24-slim

USER node
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY --chown=node:node . .
CMD  [ "yarn", "build" ]
