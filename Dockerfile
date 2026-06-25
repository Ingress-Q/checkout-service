FROM node:20-slim AS build

WORKDIR /usr/src/app

RUN corepack enable

COPY package.json yarn.lock ./
RUN yarn install --immutable

COPY . .
RUN yarn build


FROM node:20-slim

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock ./
RUN yarn install --immutable

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

USER node

ENTRYPOINT ["node", "dist/main.js"]