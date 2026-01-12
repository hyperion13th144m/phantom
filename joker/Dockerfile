FROM node:24-alpine AS deps

ENV NODE_ENV=production
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


FROM node:24-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG IMAGE_BASE_URL
ARG DOC_BASE_URL
ENV NODE_ENV=production
ENV IMAGE_BASE_URL=$IMAGE_BASE_URL
ENV DOC_BASE_URL=$DOC_BASE_URL
RUN yarn build


FROM node:24-alpine AS runner
WORKDIR /app
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/standalone ./
ENV NODE_ENV=production
EXPOSE 3000
CMD  [ "node", "server.js" ]

