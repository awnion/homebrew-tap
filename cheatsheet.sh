#!/bin/bash

brew install --formula --build-bottle awnion/tap/boost@1.83
brew bottle --json --root-url "https://ghcr.io/v2/awnion/tap" awnion/tap/boost@1.83

oras push ghcr.io/awnion/tap/boost/1.83 boost@1.83--1.83.0.arm64_sequoia.bottle.tar.gz

oras pull ghcr.io/homebrew/core/boost:1.83.0

for f in boost*; do mv "$f" "boost@1.83${f#boost}"; done

oras push ghcr.io/awnion/tap/boost/1.83:1.83 boost@1.83*


for f in boost@1.83*; do
  echo "Processing $f"
  gtar --transform='s|^boost/|boost@1.83/|' -xf "$f"
  rm -f "$f"
  gtar -czf "$f" "boost@1.83"
  rm -rf boost@1.83
done
