FROM node:20-alpine AS build
WORKDIR /usr/src/app

COPY package*.json ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build


FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN yarn install --frozen-lockfile --production

COPY --from=build /usr/src/app/dist ./dist

USER node

ENTRYPOINT ["node", "dist/main.js"]