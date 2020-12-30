defmodule BirdsAgainstMortality.Repo.Migrations.AddFieldsToDeck do
  use Ecto.Migration

  def change do
    alter table(:decks) do
      add :sitewide, :bool
      add :official, :bool
      add :name, :string
    end
  end
end
