# -------------------------
# BUILD STAGE
# -------------------------
FROM node:20-slim AS build

WORKDIR /usr/src/app

RUN corepack enable

# copy only dependency files first (better caching)
COPY package.json yarn.lock ./

# install dependencies correctly for Yarn 4
RUN yarn install --immutable

# copy source
COPY . .

# build NestJS app
RUN yarn build


# -------------------------
# RUNTIME STAGE
# -------------------------
FROM node:20-slim

WORKDIR /app

RUN corepack enable

# copy only production artifacts
COPY package.json yarn.lock ./

# install production deps (safe Yarn 4 way)
RUN yarn install --immutable

# copy compiled output
COPY --from=build /usr/src/app/dist ./dist

# optional: reduce privilege (good practice for EKS)
USER node

# start app
ENTRYPOINT ["node", "dist/main.js"]