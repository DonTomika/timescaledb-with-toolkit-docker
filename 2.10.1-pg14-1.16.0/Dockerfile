FROM timescale/timescaledb:2.10.1-pg14 AS builder

RUN apk add --update --no-cache git clang14 pkgconfig openssl-dev gcc postgresql14-dev curl make musl-dev

# allow the postgres user to install extensions
RUN chown postgres /usr/local/share/postgresql/extension /usr/local/lib/postgresql

USER postgres

ENV PATH="/var/lib/postgresql/.cargo/bin:${PATH}" RUSTFLAGS='-C target-feature=-crt-static'

WORKDIR /var/lib/postgresql

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal -c rustfmt

RUN cargo install --version '=0.7.1' cargo-pgx

RUN cargo pgx init --pg14 `which pg_config`

RUN git clone https://github.com/timescale/timescaledb-toolkit.git && \
	cd timescaledb-toolkit && \
	git checkout 1.16.0

RUN cd timescaledb-toolkit/extension && \
	cargo pgx install --release

RUN cd timescaledb-toolkit/extension && \
	cargo run --manifest-path ../tools/post-install/Cargo.toml -- pg_config

USER root

RUN chown root /usr/local/share/postgresql/extension/timescaledb_toolkit* /usr/local/lib/postgresql/timescaledb_toolkit*

FROM timescale/timescaledb:2.10.1-pg14

COPY --from=builder /usr/local/share/postgresql/extension/timescaledb_toolkit* /usr/local/share/postgresql/extension/
COPY --from=builder /usr/local/lib/postgresql/timescaledb_toolkit* /usr/local/lib/postgresql/
