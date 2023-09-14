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
    order_date:datetime \
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

### Backlog
- [x] setup base project
- [x] create form for reservation creation (:new)
- [x] implement :create
- [ ] send confirmation mail
- [ ] create some fields of reservation automatically (code, time, ...)
- [ ] deployment
- [ ] implement validation when creating reservation (incl. sold out message)
- [ ] layout