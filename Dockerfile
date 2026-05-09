FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

RUN apk add --no-cache git && \
    git config --global user.email "dev@example.com" && \
    git config --global user.name "dev"

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

FROM golang:1.23-alpine AS backend-builder

WORKDIR /app

COPY backend/ ./backend/
COPY --from=frontend-builder /app/frontend/dist ./backend/internal/web/dist

RUN echo "This file keeps the embedded dist directory in version control." > backend/internal/web/dist/.keep

WORKDIR /app/backend
RUN go build -o fusion ./cmd/fusion

FROM alpine:3.21

WORKDIR /app

RUN apk add --no-cache git && \
    git config --global user.email "dev@example.com" && \
    git config --global user.name "dev" && \
    addgroup -S fusion && adduser -S -D -H -h /fusion -G fusion fusion && \
    mkdir -p /data && chown -R fusion:fusion /data && \
    git init && git add -A && git commit -m "init" || true

COPY --from=backend-builder --chown=fusion:fusion --chmod=755 /app/backend/fusion ./fusion

ENV TZ=UTC

EXPOSE 8080

VOLUME ["/data"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=2s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/api/oidc/enabled || exit 1

CMD ["./fusion"]
