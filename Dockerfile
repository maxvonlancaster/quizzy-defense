# Multi-stage build for both frontend and backend
# This Dockerfile builds and serves the entire application

# Stage 1: Build the frontend (React/Vite)
FROM node:20-alpine AS frontend-builder

WORKDIR /app/ui

# Copy frontend package files
COPY ui/package*.json ./

# Install dependencies
RUN npm ci

# Copy frontend source
COPY ui .

# Build the frontend
RUN npm run build

# Stage 2: Build the backend (NestJS)
FROM node:20-alpine AS backend-builder

WORKDIR /app/api

# Copy backend package files
COPY api/package*.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy backend source
COPY api .

# Build the backend
RUN npm run build

# Stage 3: Production runtime
FROM node:20-alpine

WORKDIR /app

# Install dumb-init to handle signals properly
RUN apk add --no-cache dumb-init

# Create necessary directories
RUN mkdir -p /app/api /app/ui/dist /app/public

# Copy backend production files
COPY --from=backend-builder /app/api/dist ./api/dist
COPY --from=backend-builder /app/api/node_modules ./api/node_modules
COPY --from=backend-builder /app/api/package*.json ./api/

# Copy built frontend to public directory (served by NestJS)
COPY --from=frontend-builder /app/ui/dist ./public

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

# Use dumb-init to properly handle signals
ENTRYPOINT ["/sbin/dumb-init", "--"]

# Set working directory to api for startup
WORKDIR /app/api

# Start the backend server
CMD ["node", "dist/main"]
