FROM debian:bookworm-slim

LABEL maintainer="klemen.bratec@gmail.com"

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget unzip groff less ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN set -eu; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'; \
			;; \
		'arm64') \
			url='https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip'; \
			;; \
        *) echo >&2 "error: unsupported architecture '$arch'"; exit 1 ;; \
	esac; \
    wget $url -O awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# Install kubectl
RUN set -eu; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.k8s.io/release/v1.28.1/bin/linux/amd64/kubectl'; \
			sha256='e7a7d6f9d06fab38b4128785aa80f65c54f6675a0d2abef655259ddd852274e1'; \
			;; \
		'arm64') \
			url='https://dl.k8s.io/release/v1.28.1/bin/linux/arm64/kubectl'; \
			sha256='46954a604b784a8b0dc16754cfc3fa26aabca9fd4ffd109cd028bfba99d492f6'; \
			;; \
        *) echo >&2 "error: unsupported architecture '$arch'"; exit 1 ;; \
	esac; \
    wget $url -O kubectl && \
    echo "$sha256  kubectl" | sha256sum -c - && \
    mv kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Create a new user and switch to the new user
RUN useradd -ms /bin/sh cli
USER cli
WORKDIR /home/cli
