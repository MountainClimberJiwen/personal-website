#!/bin/bash
set -euo pipefail

# ============================================================
# Deploy public/ to remote nginx host
# ============================================================

PROJ_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBLIC="$PROJ_ROOT/public"

# SSH host alias from ~/.ssh/config (default: centos)
HOST="${CENTOS_HOST:-centos}"

# Remote directory served by nginx
REMOTE_DIR="${REMOTE_DIR:-/var/www/personal}"

echo "Deploying $PUBLIC → $HOST:$REMOTE_DIR"
echo

rsync -avz --progress --delete \
  -e ssh \
  --exclude='.DS_Store' \
  "$PUBLIC/" "$HOST:$REMOTE_DIR/"

echo
echo "✓ Deploy complete."
echo "  Visit: https://1boss.tech/me/"
echo "  (Note: 1boss.tech DNS must point to the remote host's IP)"
