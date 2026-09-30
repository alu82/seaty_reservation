FROM elixir:1.20.2-otp-28 AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile

COPY config config
COPY lib lib
COPY priv priv
COPY assets assets

RUN mix compile && mix assets.deploy && mix release


FROM debian:trixie-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libncurses6 \
    libstdc++6 \
    openssl \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 10001 seaty \
    && useradd --system --uid 10001 --gid seaty --home-dir /app --no-create-home seaty \
    && mkdir -p /app /data \
    && chown seaty:seaty /app /data

WORKDIR /app
COPY --from=build --chown=seaty:seaty /app/_build/prod/rel/seaty_reservation ./

ENV DATABASE_PATH=/data/seaty_reservation.db \
    LANG=C.UTF-8 \
    PORT=4000 \
    PHX_SERVER=true

USER seaty
EXPOSE 4000

# Run migrations before accepting traffic. PHX_SERVER must be absent during eval.
CMD ["sh", "-c", "unset PHX_SERVER && bin/seaty_reservation eval 'SeatyReservation.Release.migrate()' && export PHX_SERVER=true && exec bin/seaty_reservation start"]
