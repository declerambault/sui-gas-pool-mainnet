FROM rust:1.90-bullseye AS chef
WORKDIR sui
RUN apt-get update && apt-get install -y cmake clang

FROM chef AS builder
WORKDIR /
COPY Cargo.toml ./
COPY Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y libjemalloc2 ca-certificates
COPY --from=builder /target/release/sui-gas-station /usr/local/bin

COPY config.yaml /config.yaml

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

EXPOSE 8080 9184

CMD ["sui-gas-station", "--config-path", "/config.yaml"]
