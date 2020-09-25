defmodule BirdsAgainstMortality.Cards.Deck do
  use Ecto.Schema
  import Ecto.Changeset
  alias BirdsAgainstMortality.Cards.Deck
  schema "decks" do
    field :black_cards, :string
    field :white_cards, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(deck, attrs) do
    deck
    |> cast(attrs, [:white_cards, :black_cards])
    |> validate_required([:white_cards, :black_cards])
  end

  def shuffle(deck) do
    %Deck{deck | white_cards: Enum.shuffle(deck.white_cards), black_cards: Enum.shuffle(deck.black_cards)}
  end
end
