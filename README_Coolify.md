# Deploy with Coolify

Create a Git-based application in Coolify and select **Dockerfile** as its build method. Use the repository root as the base directory and `Dockerfile` as the Dockerfile location. Set **Ports Exposes** to `4000` and add the public domain.

Add a persistent volume in **Configuration → Persistent Storage** with destination path `/data`. The container runs as UID/GID `10001`, so a directory bind mount must be writable by that user. The SQLite database is stored at `/data/seaty_reservation.db` by default. Back up this volume; replacing the container without it loses reservations.

Set these runtime environment variables in Coolify:

| Variable | Value |
| --- | --- |
| `PHX_HOST` | Public hostname without `https://` |
| `SECRET_KEY_BASE` | A secret generated with `mix phx.gen.secret` |
| `SY_API_URL` | Public URL with `https://`, used in reservation emails |
| `SY_SMTP_USER` | SMTP account and sender address |
| `SY_SMTP_PASSWORD` | SMTP password |

The image sets `PORT=4000`, `PHX_SERVER=true`, and `DATABASE_PATH=/data/seaty_reservation.db`. Set `SY_MAIL_SUBJECT` if a custom email subject is needed. Keep the existing `SECRET_KEY_BASE` when moving an existing installation so existing login sessions remain valid.

The container runs Ecto migrations before starting the web server. To move the current SQLite database, stop the old application first, copy its database into the Coolify volume as `/data/seaty_reservation.db`, and ensure UID/GID `10001` can write it. Then deploy the new application. Do not run both installations against the same SQLite file.

After the first deployment, create the initial admin account if needed using the application's terminal in Coolify:

```sh
bin/seaty_reservation rpc 'SeatyReservation.Release.create_first_admin(["admin@example.com", "replace-with-a-password"])'
```
