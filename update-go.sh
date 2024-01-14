#!/bin/sh

set -eu

VERSION=$1
go install "golang.org/dl/go${VERSION}@latest"
"go${VERSION}" download

# TODO automate
echo "Update version in GOROOT in ./shell/.zshrc"

