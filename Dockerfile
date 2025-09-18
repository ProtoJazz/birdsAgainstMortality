# Build stage - using a newer Elixir image
FROM elixir:1.13-otp-24 AS build

# Set locale to avoid UTF-8 issues
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    nodejs \
    npm \
    git \
    locales \
    erlang-dev \
    erlang-public-key \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Set dummy build-time env vars
ENV DATABASE_URL=postgres://postgres:postgres@localhost/birdsAgainstMortality_prod
ENV SECRET_KEY_BASE=dummy_secret_key_base_for_build_only
ENV POOL_SIZE=10
ENV PORT=4000

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# Build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm install
COPY priv priv
COPY assets assets
RUN cd assets && npm run deploy
RUN mix phx.digest

# Compile and build release
COPY lib lib
COPY migrate.sh ./

# Compile and build release
RUN mix do compile, release birds_against_mortality

# App stage - using Debian bookworm slim for compatibility
FROM debian:bookworm-slim AS app

# Set locale for runtime as well
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y \
    openssl \
    ca-certificates \
    locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

WORKDIR /app
RUN useradd --system --create-home --shell /bin/bash app
RUN chown app:app /app
USER app:app

COPY --from=build --chown=app:app /app/_build/prod/rel/birds_against_mortality ./
COPY --from=build --chown=app:app /app/migrate.sh ./

# Make migration script executable
USER root
RUN chmod +x /app/migrate.sh
USER app:app

ENV HOME=/app
EXPOSE 4000
CMD ["bin/birds_against_mortality", "start"]