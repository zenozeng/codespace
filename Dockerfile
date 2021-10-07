FROM golang:1.17.1-bullseye

ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
    gosu sudo \
    aria2 curl certbot emacs-nox fzf git gnupg make cmake clang python3 tmux stow vim wget build-essential tree; \
    rm -rf /var/lib/apt/lists/*
    
RUN apt-get update; \
    apt-get install -y software-properties-common; \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -; \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"; \
    apt-get update && apt-get install terraform; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt && \
    cd /opt && \
    git clone --progress --verbose --depth=1 https://github.com/google/flatbuffers.git && \
    cd /opt/flatbuffers && \
    CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake -G "Unix Makefiles" && \
    make && make install && \
    flatc --version

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && install minikube-linux-amd64 /usr/local/bin/minikube

# Node.js
COPY --from=node:16.1.0 /usr/local/include/node /usr/local/include/node
COPY --from=node:16.1.0 /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:16.1.0 /usr/local/bin/node /usr/local/bin/node
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm; \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx;

# Deno
COPY --from=denoland/deno:1.14.3 /usr/bin/deno /usr/bin/deno
