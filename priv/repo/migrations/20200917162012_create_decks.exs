defmodule BirdsAgainstMortality.Repo.Migrations.CreateDecks do
  use Ecto.Migration

  def change do
    create table(:decks) do
      add :white_cards, {:array, :string}
      add :black_cards, :text

      timestamps()
    end

  end
end
