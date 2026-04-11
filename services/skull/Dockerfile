FROM node:24-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


FROM node:24-slim AS runner
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo
ARG USERNAME=node
ARG GROUPNAME=node
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next/standalone ./
COPY scripts/init-db.ts ./scripts/init-db.ts
COPY entrypoint.sh ./entrypoint.sh

RUN npm install --omit=dev --only=production
RUN chmod +x ./entrypoint.sh
USER node
EXPOSE 3000
ENTRYPOINT [ "./entrypoint.sh" ]
