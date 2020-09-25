defmodule BirdsAgainstMortality.Repo do
  use Ecto.Repo,
    otp_app: :birdsAgainstMortality,
    adapter: Ecto.Adapters.Postgres
end
