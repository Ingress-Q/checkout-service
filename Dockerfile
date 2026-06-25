# -----------------------
# BUILD STAGE
# -----------------------
FROM node:20-alpine AS build

WORKDIR /usr/src/app

# Yarn 4 support
RUN corepack enable

# Copy ONLY dependency files first (IMPORTANT)
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies (this creates Yarn state file)
RUN yarn install --immutable

# Now copy source
COPY . .

# Build app
RUN yarn build

# Safety check
RUN test -f dist/main.js


# -----------------------
# RUNTIME STAGE
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