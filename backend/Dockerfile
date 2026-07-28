FROM rust:1.97-slim AS builder

WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/backend /usr/local/bin/backend
COPY --from=builder /app/.env /app/.env
WORKDIR /app
EXPOSE 3000
CMD ["backend"]
