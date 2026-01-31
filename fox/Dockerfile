FROM node:24-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


FROM node:24-alpine
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=4321
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

USER node
WORKDIR /app
COPY --chown=node:node . .
COPY --chown=node:node --from=builder /app/node_modules ./node_modules

EXPOSE 4321
CMD  [ "yarn", "start" ]
