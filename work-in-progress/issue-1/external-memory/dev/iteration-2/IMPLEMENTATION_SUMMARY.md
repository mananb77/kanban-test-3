# Implementation Summary — Developer Iteration 2

> **Date**: 2026-04-21
> **Iteration**: 2
> **Status**: Complete

---

## What Was Implemented

Added a production-ready `Dockerfile` and `.dockerignore` at the repository root to package the Quick Poll App for Kaniko-based container builds and QA sandbox deployment.

**No application code was changed.** All modifications are strictly packaging files.

---

## Dockerfile Details

### Base Image Tag
- **Builder stage**: `node:20-bookworm-slim`
- **Runtime stage**: `node:20-bookworm-slim`

### Final Image Composition
The runtime stage contains:
- `libsqlite3-0` (runtime shared library for better-sqlite3)
- `/app/server/` — Express server and its node_modules
- `/app/client/dist/` — Pre-built React/Vite static assets
- `/app/package.json` — Root manifest

### Volume Mount Path
- **`/data`** — Persistent SQLite database volume
- `DB_PATH=/data/polls.db` — env var points `initDb()` here
- `/data` is `chown`-ed to uid/gid 10001 before the VOLUME instruction so Docker initializes the anonymous volume with correct permissions

### Non-Root User
- **UID**: 10001
- **GID**: 10001
- **User**: `appuser` / **Group**: `appgroup`
- Created with `groupadd -g 10001` + `useradd -u 10001 -g 10001 -s /bin/sh -M`

### Path Resolution
`server/index.js` resolves client assets via `path.join(__dirname, '../client/dist')`. With `WORKDIR /app` and both `server/` and `client/dist/` copied under `/app/`, the relative path resolves to `/app/client/dist/` — correct.

---

## Build Strategy

### Layer Caching
Package manifests are copied first (before source), so the expensive `npm ci` layer (which triggers native compilation of `better-sqlite3`) is only re-run when `package*.json` files change.

### Native Compilation
`better-sqlite3` requires C++ compilation during install. The builder stage installs `python3 make g++ build-essential libsqlite3-dev` for this. The runtime stage only needs `libsqlite3-0` (the shared library) — no compiler toolchain in the final image.

### Dev Dependency Pruning
`npm prune --omit=dev --prefix server` strips any dev deps from the server directory in the runtime layer. Server has no devDependencies currently, but this is defensive hygiene.

---

## Requirements Met

- [x] Multi-stage build (builder + runtime)
- [x] Builder: `node:20-bookworm-slim` + native build tools
- [x] Runtime: `node:20-bookworm-slim` + `libsqlite3-0` only
- [x] Non-root user uid/gid 10001
- [x] `EXPOSE 3001`, `ENV NODE_ENV=production PORT=3001 DB_PATH=/data/polls.db`
- [x] `VOLUME ["/data"]` with correct ownership
- [x] `.dockerignore` excludes build artifacts, db files, git, docs, work-in-progress
- [x] No changes to `server/` or `client/src/` application code
- [x] CMD starts cleanly with empty `/data` (initDb creates tables on first run)

---

## Known Limitations

- No `HEALTHCHECK` instruction — tracked separately per spec
- No docker-compose — out of scope per spec
- Final image size not measured in sandbox (no Docker daemon available); estimated ≤ 350 MB based on node:20-bookworm-slim (~70 MB) + better-sqlite3 binary + Express + static assets
