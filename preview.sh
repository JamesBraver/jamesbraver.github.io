#!/usr/bin/env bash
# Build the site and serve it locally at http://localhost:4000
# Usage: ./preview.sh [port]

set -euo pipefail

cd "$(dirname "$0")"
PORT="${1:-4000}"

export PATH="$HOME/.gem/bin:$PATH"

if ! command -v jekyll >/dev/null 2>&1; then
  echo "jekyll not found on PATH. Install it with:" >&2
  echo "  gem install github-pages    # or: bundle install" >&2
  exit 1
fi

rm -rf _site
jekyll build --trace

echo
echo "Serving _site at http://localhost:${PORT}/  (Ctrl+C to stop)"
exec python3 -m http.server "$PORT" --directory _site
