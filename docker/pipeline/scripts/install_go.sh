#! /bin/bash

cd $HOME;
curl -O https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz;
tar xf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local
