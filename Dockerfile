# -----------------------
# Build stage
# -----------------------
FROM node:20-alpine AS build

WORKDIR /usr/src/app

# IMPORTANT for Yarn 4
RUN corepack enable

COPY package.json yarn.lock ./
RUN yarn install --immutable

COPY . .

RUN yarn build

# Safety check (fail build if dist is wrong)
RUN test -f dist/main.js


# -----------------------
# Runtime stage
# -----------------------
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN dnf --setopt=install_weak_deps=False install -q -y \
    nodejs20 \
    shadow-utils \
    && dnf clean all

RUN alternatives --install /usr/bin/node node /usr/bin/node-20 90

WORKDIR /app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

EXPOSE 8080

CMD ["node", "dist/main.js"]