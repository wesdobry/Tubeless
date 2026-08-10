#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-wesdobry}"
IMAGE="${2:-tubeless}"

echo "Fetching tags for ${NAMESPACE}/${IMAGE} from Docker Hub..."
URL="https://hub.docker.com/v2/namespaces/${NAMESPACE}/repositories/${IMAGE}/tags?page_size=100"

while [[ -n "$URL" ]]; do
  RESPONSE=$(curl --fail --silent --show-error "$URL")

  echo "$RESPONSE" | jq -c '.results[]' | while read -r tag; do
    TAG=$(echo "$tag" | jq -r '.name')
    UPDATED=$(echo "$tag" | jq -r '.last_updated')

    echo ""
    echo "┌─ $TAG"
    echo "│  updated: $UPDATED"

    echo "$tag" | jq -c '.images[]?' | while read -r image; do
      PLATFORM=$(echo "$image" | jq -r '"\(.os)/\(.architecture)\(if .variant then "/" + .variant else "" end)"')
      DIGEST=$(echo "$image" | jq -r '.digest')
      SIZE=$(echo "$image" | jq -r '.size // "unknown"')

      echo "│"
      echo "├── $PLATFORM"
      echo "│   digest: $DIGEST"
      echo "│   size:   $SIZE bytes"
    done
  done

  URL=$(echo "$RESPONSE" | jq -r '.next // empty')
done

echo ""
