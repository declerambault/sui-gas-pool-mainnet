FROM rust:1.90-bullseye AS builder
WORKDIR /build
RUN apt-get update && apt-get install -y cmake clang git
COPY . .
RUN git init && git add -A && git config user.email "build@railway" && git config user.name "Railway" && git commit -m "build" || true
RUN cargo build --release

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y libjemalloc2 ca-certificates
COPY --from=builder /build/target/release/sui-gas-station /usr/local/bin
COPY config.yaml /config.yaml
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
EXPOSE 8080 9184
CMD ["sui-gas-station", "--config-path", "/config.yaml"]
