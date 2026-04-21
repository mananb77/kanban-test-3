# Implementation Plan — Developer Iteration 2

> **Date**: 2026-04-21
> **Iteration**: 2
> **Scope**: Add production Dockerfile for Kaniko build — no application code changes

---

## Objective

Package the Quick Poll App (already fully implemented in Iteration 1) into a production Docker image suitable for Kaniko build and QA sandbox deployment.

## Requirements Checklist

- [x] Multi-stage Dockerfile (builder + runtime)
- [x] Stage 1 base image: `node:20-bookworm-slim`
- [x] Stage 1 build deps: `python3`, `make`, `g++`, `build-essential`, `libsqlite3-dev`
- [x] Stage 1: Copy package manifests, run `npm ci` (postinstall cascades), copy source, run `npm run build`
- [x] Stage 2 base image: `node:20-bookworm-slim`
- [x] Stage 2 runtime dep: `libsqlite3-0` only (no compiler toolchain)
- [x] Stage 2: Non-root user uid/gid 10001
- [x] Stage 2: WORKDIR `/app`
- [x] Stage 2: Copy `server/` (with node_modules), `client/dist/`, root `package.json`
- [x] Stage 2: `npm prune --omit=dev --prefix server`
- [x] Stage 2: `EXPOSE 3001`
- [x] Stage 2: `ENV NODE_ENV=production PORT=3001 DB_PATH=/data/polls.db`
- [x] Stage 2: `VOLUME ["/data"]`
- [x] Stage 2: `USER 10001:10001`
- [x] Stage 2: `CMD ["node", "server/index.js"]`
- [x] `.dockerignore` covers node_modules, dist, db files, .git, docs, issues, work-in-progress, *.md
- [x] No application code changed (server/, client/src/)
- [x] `/data/polls.db` path preserved via DB_PATH env var; `/data` owned by 10001:10001
- [x] `path.join(__dirname, '../client/dist')` resolved correctly (server/ and client/dist/ both under /app/)

## Implementation Tasks

- [x] Write `Dockerfile` at repo root
- [x] Write `.dockerignore` at repo root
- [x] Create WIP artifacts
- [ ] Commit

## Out of Scope

- docker-compose files
- CI workflow changes
- Application routing, validation, DB schema, or UI changes
- Health-check endpoint
