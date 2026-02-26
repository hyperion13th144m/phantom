FROM node:24-alpine

ENV NODE_ENV=production
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install -g npm@11.11.0
RUN npm install
RUN mkdir /src /dst && chown node:node /src /dst
USER node
ENTRYPOINT ["npx"]
