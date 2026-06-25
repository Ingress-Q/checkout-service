# -------------------------
# BUILD STAGE
# -------------------------
FROM node:20-slim AS build

WORKDIR /usr/src/app

RUN corepack enable

# IMPORTANT: include .yarn folder
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

RUN yarn install --immutable

COPY . .

RUN yarn build


# -------------------------
# RUNTIME STAGE
# -------------------------
FROM node:20-slim

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

RUN yarn install --immutable

COPY --from=build /usr/src/app/dist ./dist

USER node

ENTRYPOINT ["node", "dist/main.js"]