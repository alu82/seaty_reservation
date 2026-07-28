#!/usr/bin/env bash

set -euo pipefail

echo "Select environment to deploy to (test, int, prod):"
read -r ENV

case "$ENV" in
  test) HOSTNAME="seaty-test" ;;
  int)  HOSTNAME="seaty-int" ;;
  prod) HOSTNAME="seaty-prod" ;;
  *) echo "Invalid environment. Please choose test, int, or prod."; exit 1 ;;
esac

echo "==> Deploying to $HOSTNAME"

echo "==> Cleaning previous release"
rm -rf _build/prod/rel/seaty_reservation

echo "==> Building Phoenix release"
podman build -t seaty-builder -f Containerfile .

echo "==> Extracting release from builder container"
podman rm -f seaty-build 2>/dev/null || true
podman create --name seaty-build seaty-builder

podman cp \
  seaty-build:/app/_build/prod/rel/seaty_reservation \
  _build/prod/rel/

podman rm seaty-build

echo "==> Stopping $HOSTNAME service"
ssh "$HOSTNAME" 'systemctl stop seaty'

echo "==> Uploading release"
rsync --delete -avz \
  _build/prod/rel/seaty_reservation/ \
  "$HOSTNAME":/opt/seaty/

echo "==> Fixing ownership"
ssh "$HOSTNAME" 'chown -R seaty:seaty /opt/seaty'

echo "==> Running database migrations"
ssh "$HOSTNAME" \
  'sudo systemd-run --wait --collect --pipe \
    --property=User=seaty \
    --property=WorkingDirectory=/opt/seaty \
    --property=EnvironmentFile=/etc/seaty/seaty.env \
    env PHX_SERVER=false \
    /opt/seaty/bin/seaty_reservation eval "SeatyReservation.Release.migrate()"'

echo "==> Starting $HOSTNAME service"
ssh "$HOSTNAME" 'systemctl start seaty'

echo "==> Checking service status"
ssh "$HOSTNAME" 'systemctl is-active --quiet seaty'

echo "==> Deployment completed successfully"
