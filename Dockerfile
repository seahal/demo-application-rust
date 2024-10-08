FROM rust:1.80.1-slim-bookworm AS development
RUN mkdir /cargos
WORKDIR /cargo
RUN rustup self update
RUN rustup update
RUN rustup component add clippy rust-analyzer rustfmt
RUN rustup target add aarch64-unknown-linux-musl
COPY ./ ./
# TODO: 本当は各ディレクトリの Cargo とかのファイルだけを移設したいけど、やりかたがわからんのだ
RUN export CGO_ENABLED=0
RUN ls -F | grep '/' | xargs -I {} bash -c 'cd ./{}; cargo build --release --target aarch64-unknown-linux-musl'

FROM gcr.io/distroless/static-debian12 AS production
#USER node
WORKDIR /usr/local/bin
COPY --from=development /rust/target/aarch64-unknown-linux-musl/release /usr/local/bin
CMD ["./sample"]
