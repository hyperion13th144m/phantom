FROM node:24-slim AS deps

ENV NODE_ENV=production
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


FROM node:24-slim AS builder
ENV NODE_ENV=production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build


FROM node:24-slim AS runner
ENV NODE_ENV=production
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo
ARG USERNAME=node
ARG GROUPNAME=node
USER node
WORKDIR /app
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/standalone ./
EXPOSE 3000
CMD  [ "node", "server.js" ]

