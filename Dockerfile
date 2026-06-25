FROM node:20-alpine AS build

WORKDIR /usr/src/app

# Enable corepack
RUN corepack enable

# Force Yarn 4 install via corepack (IMPORTANT)
RUN corepack prepare yarn@4.11.0 --activate

# Copy only dependency files first
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --immutable

# Copy rest of code
COPY . .

# Build
RUN yarn build

RUN test -f dist/main.js


FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN dnf --setopt=install_weak_deps=False install -q -y \
    nodejs20 shadow-utils && dnf clean all

WORKDIR /app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

CMD ["node", "dist/main.js"]