#!/usr/bin/env bash
set -euo pipefail

IMAGE="yonas:${BUILDKITE_COMMIT}"
CONTAINER="yonas"

# The Rails master key must be available to decrypt credentials (Discord token).
# Either export RAILS_MASTER_KEY in the agent's `environment` hook, or place the
# key on the Pi at /etc/yonas/master.key (chmod 600, owned by buildkite-agent).
if [[ -z "${RAILS_MASTER_KEY:-}" && -r /etc/yonas/master.key ]]; then
  RAILS_MASTER_KEY="$(< /etc/yonas/master.key)"
fi
if [[ -z "${RAILS_MASTER_KEY:-}" ]]; then
  echo "^^^ +++"
  echo "RAILS_MASTER_KEY is not set and /etc/yonas/master.key was not found" >&2
  exit 1
fi

echo "--- :docker: Replacing container ${CONTAINER} with ${IMAGE}"
docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true

docker run -d \
  --name "${CONTAINER}" \
  --restart unless-stopped \
  -e RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \
  -p 3001:3001 \
  -v yonas-storage:/rails/storage \
  "${IMAGE}"

echo "--- :stethoscope: Waiting for the app to boot"
for _ in $(seq 1 30); do
  if curl -fsS http://localhost:3001/up >/dev/null 2>&1; then
    echo "App is up"
    docker logs --tail 10 "${CONTAINER}"
    echo "--- :broom: Pruning dangling images"
    docker image prune -f
    exit 0
  fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "${CONTAINER}" 2>/dev/null)" != "true" ]]; then
    break
  fi
  sleep 2
done

echo "^^^ +++"
echo "App failed to become healthy" >&2
docker logs --tail 50 "${CONTAINER}" || true
exit 1
