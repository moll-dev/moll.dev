FROM microsoft/vsts-agent:ubuntu-16.04


MAINTAINER tom@moll.dev

# Install pygments (for syntax highlighting)
# RUN apt-get -qq update \
#         && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends python-pygments git ca-certificates asciidoc \
#         && rm -rf /var/lib/apt/lists/*

# Download and install hugo

ENV GO_VERSION=1.12.9               \
    GOPATH=/usr/local/go            

ENV HOME=/root                      \
    PATH=$PATH:${GOPATH}/bin        \
    HUGO_BRANCH=stable



RUN apt-get update -y; apt-get install -y curl git

COPY scripts/install_go.sh ${HOME}/install_go.sh
RUN chmod +x ${HOME}/install_go.sh; bash +x ${HOME}/install_go.sh


COPY scripts/install_hugo.sh ${HOME}/install_hugo.sh
RUN chmod +x ${HOME}/install_hugo.sh; bash +x ${HOME}/install_hugo.sh

# RUN cd $HOME; curl -O https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz 
# RUN tar xf go${GO_VERSION}.linux-amd64.tar.gz -C $HOME
# RUN export PATH=$PATH:${GOPATH}/bin;

#RUN mkdir $HOME/src;            \
#    cd $HOME/src;               \
#    git clone --single-branch --branch ${HUGO_BRANCH} https://github.com/gohugoio/hugo; \
#    cd hugo; /usr/local/go/bin install;


# ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} /tmp/hugo.deb
# RUN dpkg -i /tmp/hugo.deb \
#         && rm /tmp/hugo.deb

# # Create working directory
# RUN mkdir /usr/share/blog
# WORKDIR /usr/share/blog

CMD /bin/sh