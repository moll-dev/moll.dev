FROM microsoft/vsts-agent:ubuntu-16.04

MAINTAINER tom@moll.dev

# Install pygments (for syntax highlighting)
RUN apt-get -qq update \
         && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends python-pygments git ca-certificates asciidoc \
        && rm -rf /var/lib/apt/lists/*

# Download and install hugo

ENV GO_VERSION=1.15.6               \
    GOPATH=/usr/local/go            

ENV HOME=/root                      \
    PATH=$PATH:${GOPATH}/bin        \
    HUGO_BRANCH=stable



RUN apt-get update -y; apt-get install -y curl git

COPY scripts/install_go.sh ${HOME}/install_go.sh
RUN chmod +x ${HOME}/install_go.sh; bash +x ${HOME}/install_go.sh


COPY scripts/install_hugo.sh ${HOME}/install_hugo.sh
RUN chmod +x ${HOME}/install_hugo.sh; bash +x ${HOME}/install_hugo.sh

CMD /bin/sh