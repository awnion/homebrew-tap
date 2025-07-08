brew install --formula --build-bottle awnion/tap/boost@1.83
brew bottle --json --root-url "https://ghcr.io/v2/awnion/homebrew-tap" awnion/tap/boost@1.83

oras push ghcr.io/awnion/tap/boost/1.83 boost@1.83--1.83.0.arm64_sequoia.bottle.tar.gz

oras pull ghcr.io/homebrew/core/boost:1.83.0

for f in boost*; do mv "$f" "boost@1.83${f#boost}"; done

for f in boost@1.83*; do
  sha256=$(shasum -a 256 "$f" | awk '{print $1}')
  echo "$sha256  $f"
  oras push ghcr.io/awnion/tap/boost/1.83 "$f"
done
