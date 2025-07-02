# Build stage - using a Debian-based image for better compatibility
FROM elixir:1.11 AS build

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    nodejs \
    npm \
    git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

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

# Create a release configuration file if it doesn't exist
RUN mkdir -p rel
RUN echo 'import Config' > rel/config.exs

# Compile and build release with a valid name
RUN mix do compile, release birds_against_mortality

# App stage - using Debian slim for compatibility
FROM debian:bullseye-slim AS app

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y \
    openssl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN useradd --system --create-home --shell /bin/bash app
RUN chown app:app /app
USER app:app

COPY --from=build --chown=app:app /app/_build/prod/rel/birds_against_mortality ./

ENV HOME=/app
EXPOSE 4000
CMD ["bin/birds_against_mortality", "start"]