# SeatyReservation

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


### Setup
create app with ```mix phx.new seaty_reservation --database sqlite3```

create and migrate to schema with
```
mix phx.gen.html Events Event events \
    datetime:naive_datetime \
    total_seats:integer \
    active:boolean

mix phx.gen.html Reservations Reservation reservations \
    prio:integer \
    seats:integer \
    code:string \
    name:string \
    contact:string \
    group:integer \
    preferred_row:string \
    event_id:references:events \
    comment:text

mix ecto.migrate
```

### DB Migration
```
mix ecto.gen.migration <name>

mix ecto.migrate
```

### Deployment to render
Follow roughly this guide: https://render.com/docs/deploy-phoenix
- Set name
- Instance type 0.5 CPU, 512 MB (can't use the free tier, since we need a disk)
- Repo: https://github.com/alu82/seaty_reservation
- Branch: main
- Build command: ./build.sh
- Start command: mix phx.server
- Under advanced
  - Add a disk and mount under /data
  - Environment variables
    - DATABASE_PATH=/data/db/...
    - ELIXIR_VERSION=1.15.4
    - ERLANG_VERSION=26.0.2
    - SECRET_KEY_BASE
    - SY_BASIC_AUTH_PASSWORD
    - SY_BASIC_AUTH_USER
    - SY_MAIL_SUBJECT
    - SY_SMTP_PASSWORD
    - SY_SMTP_USER

### Backlog
- [x] setup base project
- [x] create form for reservation creation (:new)
- [x] implement :create
- [x] send confirmation mail
- [x] create some fields of reservation automatically (code, time, ...)
- [x] deployment
- [x] implement validation when creating reservation (incl. sold out message)
- [x] custom edit form, option to resend email confirmation when editing
- [x] retry when cration failed due to duplicate code
- [x] layout
- [x] localization, texts (for customer facing pages)
- [x] dataprivacy text
- [x] route access restrictions
- [x] make user comment field multiline
- [x] make additional comment field, so that user comment must not be edited
- [ ] Confirmation Page on mobile devices (text to long, overlays with reservation number)
- [ ] No event (date) should be selected when loading the page
- [ ] Cancel reservation feature
- [ ] simple captcha?
- [ ] localization, texts (for restricted pages)
 