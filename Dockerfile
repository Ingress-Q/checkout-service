FROM node:20-alpine AS build

WORKDIR /usr/src/app
RUN corepack enable

COPY package*.json ./
COPY . .

RUN yarn install --immutable
RUN yarn build


FROM node:20-alpine

WORKDIR /app
RUN corepack enable

COPY package*.json ./

# ✅ correct Yarn 4 production install
RUN yarn workspaces focus --all --production

COPY --from=build /usr/src/app/dist ./dist

USER node

ENTRYPOINT ["node", "dist/main.js"]