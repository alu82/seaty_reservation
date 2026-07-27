#!/usr/bin/env bash

set -euo pipefail

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

echo "==> Stopping production service"
ssh seaty-prod 'systemctl stop seaty'

echo "==> Uploading release"
rsync --delete -avz \
  _build/prod/rel/seaty_reservation/ \
  seaty-prod:/opt/seaty/

echo "==> Fixing ownership"
ssh seaty-prod 'chown -R seaty:seaty /opt/seaty'

echo "==> Running database migrations"
ssh seaty-prod \
  'sudo systemd-run --wait --collect --pipe \
    --property=User=seaty \
    --property=WorkingDirectory=/opt/seaty \
    --property=EnvironmentFile=/etc/seaty/seaty.env \
    env PHX_SERVER=false \
    /opt/seaty/bin/seaty_reservation eval "SeatyReservation.Release.migrate()"'

echo "==> Starting production service"
ssh seaty-prod 'systemctl start seaty'

echo "==> Checking service status"
ssh seaty-prod 'systemctl is-active --quiet seaty'

echo "==> Deployment completed successfully"