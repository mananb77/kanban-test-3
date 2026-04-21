# Stage 1: Builder — compile better-sqlite3 native addon and build client
FROM node:20-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ build-essential libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package manifests first for layer-cache efficiency
COPY package.json package-lock.json ./
COPY client/package.json client/package-lock.json ./client/
COPY server/package.json server/package-lock.json ./server/

# postinstall cascades npm install into client/ and server/
RUN npm ci

# Copy full source tree and build the React client
COPY . .
RUN npm run build

# Stage 2: Runtime — minimal image, no compiler toolchain
FROM node:20-bookworm-slim AS runtime

# Only the shared library that better-sqlite3 links against at load time
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-0 \
  && rm -rf /var/lib/apt/lists/*

# Non-root user: uid/gid 10001
RUN groupadd -g 10001 appgroup \
  && useradd -u 10001 -g 10001 -s /bin/sh -M appuser

WORKDIR /app

# Copy only what the server needs at runtime
COPY --from=builder /app/server ./server
COPY --from=builder /app/client/dist ./client/dist
COPY --from=builder /app/package.json ./

# Strip dev dependencies (server has none, but good hygiene)
RUN npm prune --omit=dev --prefix server \
  && mkdir /data \
  && chown -R 10001:10001 /app /data

EXPOSE 3001

ENV NODE_ENV=production \
    PORT=3001 \
    DB_PATH=/data/polls.db

# /data is the persistent SQLite volume; initDb() creates the file on first start
VOLUME ["/data"]

USER 10001:10001

CMD ["node", "server/index.js"]
