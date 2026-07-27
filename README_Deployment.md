# Phoenix Deployment Guide

This guide describes how to deploy the Seaty Phoenix application to a freshly provisioned server.

---

## 0. Prerequisites (once)

Configure `~/.ssh/config`

```sh
Host seaty-prod
    HostName <host-ip>
    User root
    IdentityFile <path-to-ssh>
```

## 1. Configure DNS (once)

Create an **AAAA** record in Cloudflare.

Example:

| Type | Name | Content                 |
| ---- | ---- | ----------------------- |
| AAAA | @    | `<server IPv6 address>` |

Enable the Cloudflare proxy (orange cloud).

Restart Caddy.

---

## 2. Configure environment variables (once)

The following environment variables are required in `/etc/seaty/seaty.env`:

```sh
PHX_SERVER=true
PORT=4000
PHX_HOST=example.com
DATABASE_PATH=/var/lib/seaty/seaty_test.db
SECRET_KEY_BASE=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

SY_API_URL=https://example.com
SY_BASIC_AUTH_USER=user
SY_BASIC_AUTH_PASSWORD=xxxxxxxxxxxxxxxxx

SY_SMTP_USER=mail@example.com
SY_SMTP_PASSWORD='xxxxxxxxxxxxxxxxxxxxxxxxx'

SY_MAIL_SUBJECT=Int
```

Afterwards setting the variables change the permissions.

```sh
chown root:seaty /etc/seaty/seaty.env
chmod 640 /etc/seaty/seaty.env
```

---

## 3. Build the release

### With the container build file

```bash
rm -rf _build/prod/rel/seaty_reservation 

# Build image
podman build -t seaty-builder -f Containerfile .

# Create temporary container
podman create --name seaty-build seaty-builder

# Extract release
podman cp seaty-build:/app/_build/prod/rel/seaty_reservation _build/prod/rel/

# Remove temporary container
podman rm seaty-build
```

## 3. Upload the release

Copy the release to the server:

```bash
ssh seaty-prod 'systemctl stop seaty'
```

```bash
rsync --delete -avz \
  _build/prod/rel/seaty_reservation/ \
  seaty-prod:/opt/seaty/
```

The release should be owned by the application user:

```bash
ssh seaty-prod 'chown -R seaty:seaty /opt/seaty'
```

---

## 5. Run database migrations

Execute the release migration command:

```bash
ssh seaty-prod \
  'sudo systemd-run --wait --collect --pipe \
    --property=User=seaty \
    --property=WorkingDirectory=/opt/seaty \
    --property=EnvironmentFile=/etc/seaty/seaty.env \
    env PHX_SERVER=false \
    /opt/seaty/bin/seaty_reservation eval "SeatyReservation.Release.migrate()"'
```

---

## 6. Start the application

```bash
ssh seaty-prod 'systemctl start seaty'
```

Enable automatic startup:

```bash
ssh seaty-prod 'systemctl enable seaty'
```

---

## 7. Useful commands

Check the application status:

```bash
systemctl status seaty
```

View application logs:

```bash
journalctl -u seaty -f
```

Verify that Phoenix is listening:

```bash
ss -ltnp
```

Expected:

```sh
0.0.0.0:4000
```

or

```sh
[::]:4000
```

Caddy status:

```bash
systemctl status caddy
```

Caddy logs:

```bash
journalctl -u caddy -f
```

Memory usage:

```bash
free -h
```

Disk usage:

```bash
df -h
```
