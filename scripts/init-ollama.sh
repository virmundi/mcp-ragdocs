#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MODEL="${OLLAMA_EMBEDDING_MODEL:-nomic-embed-text}"
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

export OLLAMA_HOST

echo "Starting Qdrant and Ollama..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d qdrant ollama

echo "Waiting for Ollama at $OLLAMA_HOST..."
for _ in {1..30}; do
  if curl --silent --fail "$OLLAMA_HOST/api/tags" >/dev/null; then
    break
  fi
  sleep 2
done

if ! curl --silent --fail "$OLLAMA_HOST/api/tags" >/dev/null; then
  echo "Ollama did not become ready at $OLLAMA_HOST" >&2
  exit 1
fi

echo "Pulling Ollama embedding model: $MODEL"
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T ollama ollama pull "$MODEL"
echo "Ollama embedding configuration initialized."
