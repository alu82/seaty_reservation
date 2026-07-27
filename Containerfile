FROM docker.io/library/elixir:1.20.2-otp-28 as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

# Install dependencies first for better layer caching
COPY mix.exs mix.lock ./

RUN mix deps.get
RUN mix deps.compile

# Copy application files
COPY config config
COPY lib lib
COPY priv priv
COPY assets assets

# Compile application
RUN MIX_ENV=prod mix compile

# Build static assets
RUN MIX_ENV=prod mix assets.deploy

# Build production release
RUN MIX_ENV=prod mix release