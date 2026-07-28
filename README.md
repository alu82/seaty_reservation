# SeatyReservation

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: <https://www.phoenixframework.org/>
* Guides: <https://hexdocs.pm/phoenix/overview.html>
* Docs: <https://hexdocs.pm/phoenix>
* Forum: <https://elixirforum.com/c/phoenix-forum>
* Source: <https://github.com/phoenixframework/phoenix>

## Setup

create app with ```mix phx.new seaty_reservation --database sqlite3```

create and migrate to schema with

```sh
mix ecto.migrate
```

## DB Migration

```sh
mix ecto.gen.migration <name>

mix ecto.migrate
```

## Deployment

For a Deployment to a Scaleway VPS see [Deployment Guide](README_Deployment.md).

After Reading and understanding it, just execute `build-deploy.sh`.

## Backlog

* [x] setup base project
* [x] create form for reservation creation (:new)
* [x] implement :create
* [x] send confirmation mail
* [x] create some fields of reservation automatically (code, time, ...)
* [x] deployment
* [x] implement validation when creating reservation (incl. sold out message)
* [x] custom edit form, option to resend email confirmation when editing
* [x] retry when cration failed due to duplicate code
* [x] layout
* [x] localization, texts (for customer facing pages)
* [x] dataprivacy text
* [x] route access restrictions
* [x] make user comment field multiline
* [x] make additional comment field, so that user comment must not be edited
* [x] Confirmation Page on mobile devices (text to long, overlays with reservation number)
* [x] No event (date) should be selected when loading the page
* [x] show available seats (when inactive available seat are shown, filter which event is shown based on time)
* [ ] cancel reservation template --> [Story](.agent/tasks/001_Cancellation-Mail.md)
* [ ] print ticket feature
* [ ] allocation endpoint
* [ ] Cancel reservation feature (until event hasn't started)
* [ ] simple captcha?
* [ ] localization, texts (for restricted pages)
* [ ] ics file in confirmation mail
