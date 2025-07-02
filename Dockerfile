# Build stage - using a Debian-based image for better compatibility
FROM elixir:1.11 AS build

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
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

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

# Debug: Check what's in the config directory
RUN echo "=== Config files before release ===" && ls -la config/

# Compile and build release
RUN mix do compile, release birds_against_mortality

# Debug: Check what's in the release directory
RUN echo "=== Release structure ===" && find _build/prod/rel/birds_against_mortality -name "*.exs" -o -name "*.ex" | head -20

# Check if there's a runtime.exs file being generated
RUN if [ -f "_build/prod/rel/birds_against_mortality/releases/0.1.0/runtime.exs" ]; then \
    echo "=== Found runtime.exs, contents: ===" && \
    cat _build/prod/rel/birds_against_mortality/releases/0.1.0/runtime.exs; \
    else echo "=== No runtime.exs found ==="; \
    fi

# App stage - using Debian slim for compatibility
FROM debian:bullseye-slim AS app

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

ENV HOME=/app
EXPOSE 4000
CMD ["bin/birds_against_mortality", "start"]