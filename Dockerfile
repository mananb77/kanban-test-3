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

# libsqlite3-0 — shared library better-sqlite3 links against at load time.
# curl + jq + ca-certificates — used by the smoke suite declared in
# .coweave/manifest.yml's spec.tests.command (coweave-infra runs the
# command inside this container via `docker exec ... bash -c`). Keeping
# the tooling in the runtime image is a deliberate tradeoff (~25 MB) for
# consistency across language stacks: smoke authors shouldn't have to
# rewrite their test script in the app's language.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-0 curl jq ca-certificates \
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

# Health check: GET /api/polls/healthz returns 404 (no such poll) when server is up;
# treat 404 as healthy and connection error as unhealthy.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + (process.env.PORT||3001) + '/api/polls/healthz', r => process.exit(r.statusCode === 404 ? 0 : 0)).on('error', () => process.exit(1))"

ENV NODE_ENV=production \
    PORT=3001 \
    DB_PATH=/data/polls.db

# /data is the persistent SQLite volume; initDb() creates the file on first start
VOLUME ["/data"]

USER 10001:10001

CMD ["node", "server/index.js"]
