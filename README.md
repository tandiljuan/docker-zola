This repository contains the `Dockerfile` to compile [Zola](https://github.com/getzola/zola) and create a container image for this application.

Taken from its repository description, Zola is a fast [static site generator](https://en.wikipedia.org/wiki/Static_site_generator) in a single binary with everything built-in.

The container image is available on [Docker Hub](https://hub.docker.com/r/tandiljuan/zola). However, if you want to build it, you need to run the following command.

```bash
export RUST_VERSION="1.79" && \
export ZOLA_VERSION="0.19.2" && \
docker build \
    --build-arg="RUST_VERSION=${RUST_VERSION}" \
    --build-arg="ZOLA_VERSION=${ZOLA_VERSION}" \
    --tag="tandiljuan/zola:${ZOLA_VERSION}" \
    --tag="tandiljuan/zola" \
    --target 'zola' .
```

The Rust and Zola versions are mandatory. At the time of writing this documentation, I have used Zola version `0.19.2` and Rust version `1.79` (the minimum version required by Zola). The Rust version is managed by [`rustup`](https://rust-lang.github.io/rustup/concepts/toolchains.html), and the Zola version is one of the repository's [`tags`](https://github.com/getzola/zola/tags) (without using the letter `v`).

Once the build process finishes, Zola can be run from the image with the following command.

```bash
docker run \
    --interactive \
    --tty \
    --rm  \
    --user "$(id -u):$(id -g)" \
    --volume "${PWD}:/app" \
    tandiljuan/zola
```

The server can be run with the following command.

```bash
docker run \
    --interactive \
    --tty \
    --rm  \
    --user "$(id -u):$(id -g)" \
    --volume "${PWD}:/app" \
    --publish 3131:3131 \
    --publish 1024:1024 \
    tandiljuan/zola \
    serve --interface 0.0.0.0 --port 3131 --base-url localhost
```

To check if the server is running properly, use a browser to go to [`http://localhost:3131`](http://localhost:3131) or run the following command.

```bash
curl --verbose http://localhost:3131
```
