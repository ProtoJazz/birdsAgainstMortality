# Use a base image that closely matches Elixir 1.10.1 and Erlang 22.3.1
FROM elixir:1.10.1-slim

# Install any necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and set the application directory
RUN mkdir /opt/app
WORKDIR /opt/app

ENV MIX_ENV=prod
ENV LANG=C.UTF-8

# Copy mix.exs and mix.lock files for dependency installation first
COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Copy the entire application source code
COPY . .

# Install dependencies and compile
RUN mix deps.compile && \
    mix compile

# Set up the application assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# Set up the database, if needed. You may need to customize this based on your setup.
RUN mix ecto.create && mix ecto.migrate

# Expose the port your app will run on
EXPOSE 4000

# Command to run the application
CMD ["mix", "phx.server"]
