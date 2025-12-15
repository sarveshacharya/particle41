FROM node:lts-alpine3.23 AS base

FROM base AS builder
WORKDIR /app
RUN npm i -g @nestjs/cli typescript ts-node
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM base AS production
WORKDIR /app

RUN addgroup -S app && adduser -S app -G app

COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/package.json ./package.json

USER app

EXPOSE 3002
CMD ["node", "dist/main"]
