# === 1. Build React App ===
FROM node:20-bookworm-slim AS frontend-builder

WORKDIR /app
COPY frontend/package*.json ./
RUN npm install --legacy-peer-deps
COPY frontend .
RUN npm run build

# === 2. Build Deno App ===
FROM denoland/deno:alpine-2.4.1

# App directory
WORKDIR /app
COPY . .

# Copy frontend build output into Deno's static folder
COPY --from=frontend-builder /app/dist ./frontend/dist

# Set environment variables
ENV PORT=60421
ENV DENO_ENV=production

EXPOSE 60421

# Cache dependencies
RUN deno cache main.ts

# Run as non-root
USER deno

# Run Deno server
ENTRYPOINT ["deno", "run", "--allow-net", "--allow-env", "--allow-sys", "--allow-read", "main.ts"]