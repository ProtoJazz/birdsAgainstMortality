FROM erlang:22.3.1

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

RUN curl -sL https://github.com/elixir-lang/elixir/releases/download/v1.10.1/Precompiled.zip -o elixir.zip \
    && unzip elixir.zip -d /usr/lib/elixir \
    && echo 'export PATH="$PATH:/usr/lib/elixir/bin"' >> /root/.bashrc \
    && source /root/.bashrc \
    && rm elixir.zip

ENV MIX_ENV=prod
ENV LANG=C.UTF-8

COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

COPY . .

RUN mix deps.compile && \
    mix compile

RUN mix phx.digest
RUN mix release --env=prod

EXPOSE 4000

CMD ["sh", "-c", "bin/birdsAgainstMortality start"]
