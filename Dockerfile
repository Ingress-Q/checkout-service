FROM node:20-slim AS build

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

RUN yarn install --immutable

COPY . .

RUN yarn build


FROM node:20-slim

WORKDIR /app

COPY --from=build /app ./

USER node

CMD ["node", "dist/main.js"]