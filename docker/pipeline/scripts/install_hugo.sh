#! /bin/bash

mkdir $HOME/src
cd $HOME/src
git clone --single-branch --branch ${HUGO_BRANCH} https://github.com/gohugoio/hugo
cd hugo
go install