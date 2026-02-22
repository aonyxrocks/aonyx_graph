ARG VARIANT="v1.14.0-erlang"
FROM ghcr.io/gleam-lang/gleam:$VARIANT

RUN apt-get update && apt-get install -y \
    git \
    nodejs \
    inotify-tools \
    entr \
    && apt-get clean
