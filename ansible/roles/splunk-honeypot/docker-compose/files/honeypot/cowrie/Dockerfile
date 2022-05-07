# Base Image
FROM debian:buster-slim AS base
#
ENV STDOUT=yes
#
RUN groupadd -r -g 1000 cowrie && \
    useradd -r -u 1000 -d /home/cowrie -m -g 1000 cowrie && \
    apt-get update && \
    apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
            python3
#
# Builder Image
FROM base AS builder
#
RUN apt-get install -y \
        build-essential \
        cargo \
        git \
        libffi-dev \
        libsnappy-dev \
        libssl-dev \
        python3-dev \
        python3-pip \
        python3-venv \
        python3-virtualenv \
        rustc && \
    rm -rf /var/lib/apt/lists/*
#
USER cowrie
#
ARG COWRIE_VERSION="v2.3.0"
#
WORKDIR /home/cowrie
#
RUN git clone --depth=1 https://github.com/cowrie/cowrie -b ${COWRIE_VERSION} ./cowrie-git && \
    python3 -m venv cowrie-env && \
    . cowrie-env/bin/activate && \
    pip install --no-cache-dir --upgrade \
        cffi \
        pip \
        -r /home/cowrie/cowrie-git/requirements.txt \
        -r /home/cowrie/cowrie-git/requirements-output.txt && \
    rm -rf /home/.cache
#
# Runtime Image
FROM base as runtime
#
RUN apt-get install -y \
        -o APT::Install-Suggests=false \
        -o APT::Install-Recommends=false \
      libffi6 \
      libssl1.1 \
      procps && \
    rm -rf /var/lib/apt/lists/* 
#
RUN ln -s /usr/bin/python3 /usr/local/bin/python
#
COPY --from=builder /home /home
#
USER cowrie
#
ENV PATH=/home/cowrie/cowrie-git/bin:$PATH
#
WORKDIR /home/cowrie/cowrie-git
#
CMD [ "cowrie", "start", "-n" ]
