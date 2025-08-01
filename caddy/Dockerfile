# docker/caddy/Dockerfile

FROM caddy:2.9.1-builder-alpine AS builder

RUN xcaddy build v2.9.1 \
    --with github.com/caddy-dns/route53@v1.5.0

FROM caddy:2.9.1-alpine AS runtime
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
