ARG BASE_IMG="ubuntu:22.04"
FROM $BASE_IMG
RUN apt-get update && apt-get install -y --no-install-recommends \
    git-lfs \
    jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./pixi.* /pixi/
