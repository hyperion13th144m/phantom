FROM node:24-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


FROM node:24-alpine
USER node
WORKDIR /app
COPY --chown=node:node . .
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
CMD  [ "yarn", "build" ]
