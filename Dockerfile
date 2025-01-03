# ------------------------------------------------------------------------------
# This is a [multi-stage build](https://docs.docker.com/build/building/multi-stage/)
# ------------------------------------------------------------------------------

# Stage: build
# ============

FROM alpine:3.21 AS build

# Build arguments
ARG RUST_VERSION
ARG ZOLA_VERSION

# This 'build' [stage](https://docs.docker.com/build/building/multi-stage/)
# doesn't need to be optimized. Therefore, the following commands will each have
# their own `RUN` instruction (image layer), as this stage will be discarded.

# Install the following packages:
# - rustup: The official Rust toolchain installer.
# - build-base: Needed because `rustup` doesn't check for a compiler toolchain.
RUN apk add --no-cache build-base rustup

# Set `/opt` as the workspace
WORKDIR /opt

# Define the installation directories for `rustup` and `cargo`
ENV RUSTUP_HOME="/opt/rustup"
ENV CARGO_HOME="/opt/cargo"

# Check if the Rust version has been defined
RUN test -n "${RUST_VERSION}"

# Install Rust toolchain
RUN rustup-init -y \
    --no-modify-path \
    --default-toolchain="${RUST_VERSION}"

# Update `$PATH` environment variable with Rust toolchain path
ENV PATH="$CARGO_HOME/bin:$PATH"

# Check if the Zola version has been defined
RUN test -n "${ZOLA_VERSION}"

# Download Zola code
RUN wget "https://github.com/getzola/zola/archive/refs/tags/v${ZOLA_VERSION}.zip"

# Extract code from zip file
RUN unzip "v${ZOLA_VERSION}.zip"

# Compile Zola code
RUN cd "zola-${ZOLA_VERSION}" && \
    cargo install --path . --locked

# ------------------------------------------------------------------------------

# Stage: zola
# ===========

FROM alpine:3.21 AS zola

# Build arguments
ARG ZOLA_VERSION

# Copy the Zola binary from the build stage into the executable directory
COPY --from=build "/opt/zola-${ZOLA_VERSION}/target/release/zola" /usr/bin/

# Create a custom workspace directory
RUN mkdir -p /app

# Set it as the working directory
WORKDIR /app

# Set the Zola binary as the entry point
ENTRYPOINT ["/usr/bin/zola"]
