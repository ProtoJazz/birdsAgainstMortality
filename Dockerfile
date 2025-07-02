FROM elixir:1.10.1-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/app
WORKDIR /opt/app

ENV MIX_ENV=prod
ENV LANG=C.UTF-8

COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

COPY . .

RUN mix deps.compile && \
    mix compile

RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

RUN mix do compile, release

EXPOSE 4000

CMD ["sh", "-c", "_build/prod/rel/birds_against_mortality/bin/birds_against_mortality start"]
