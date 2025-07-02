# Build stage
FROM elixir:1.12-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git python3 nodejs npm

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# Build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# Compile and build release
COPY lib lib
RUN mix do compile, release

# App stage
FROM alpine:3.16 AS app

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/birdsAgainstMortality ./

ENV HOME=/app

EXPOSE 4000

CMD ["bin/birdsAgainstMortality", "start"]