# syntax=docker/dockerfile:1.7

# ----------------------
# 1) Install deps (cacheable)
# ----------------------
FROM node:22-alpine AS deps
ARG service
WORKDIR /src/${service}
COPY ${service}/package*.json ./
# If you have a package-lock.json, keep 'npm ci'. Otherwise replace with:
# RUN npm install
RUN npm i

# ----------------------
# 2) Build TypeScript
# ----------------------
FROM node:22-alpine AS build
ARG service
WORKDIR /src/${service}
COPY --from=deps /src/${service}/node_modules ./node_modules
COPY ${service}/ ./
RUN npm run build

# ----------------------
# 3) Runtime image (prod deps only)
# ----------------------
FROM node:22-alpine AS runtime
ARG service
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.title=${service}
LABEL org.opencontainers.image.description="node service"
LABEL org.opencontainers.image.url="https://github.com/mouhsen-ibrahim/github-actions"
LABEL org.opencontainers.image.documentation="https://github.com/mouhsen-ibrahim/github-actions#readme"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.licenses="MIT"
ENV NODE_ENV=production
WORKDIR /src/${service}
RUN apk add --no-cache tini

# Install only production dependencies
COPY ${service}/package*.json ./
# If no package-lock.json, use: RUN npm install --omit=dev --no-audit --no-fund
RUN npm i --omit=dev --no-audit --no-fund && npm cache clean --force

# Bring in compiled JS
COPY --from=build /src/${service}/dist ./dist

# Non-root for safety
USER node

# App port (your server defaults to 3000)
EXPOSE 3000

STOPSIGNAL SIGTERM
ENTRYPOINT ["tini", "--"]
CMD [ "node", "dist/server.js" ]
