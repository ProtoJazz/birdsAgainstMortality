defmodule BirdsAgainstMortality.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias BirdsAgainstMortality.Repo

  alias BirdsAgainstMortality.Cards.Deck

  @doc """
  Returns the list of decks.

  ## Examples

      iex> list_decks()
      [%Deck{}, ...]

  """
  def list_decks do
    Repo.all(Deck)
  end

  def get_sitewide_decks do
    Deck
    |> where(sitewide: true)
    |> Repo.all()
  end

  @doc """
  Gets a single deck.

  Raises `Ecto.NoResultsError` if the Deck does not exist.

  ## Examples

      iex> get_deck!(123)
      %Deck{}

      iex> get_deck!(456)
      ** (Ecto.NoResultsError)

  """

  def get_deck!(id) do
    dbDeck = Repo.get!(Deck, id)
    %Deck{dbDeck | black_cards: Jason.decode!(dbDeck.black_cards, %{keys: :atoms})}
  end

  def get_deck(id) do
    dbDeck = Repo.get(Deck, id)
    if(is_nil(dbDeck)) do
      nil
    else
    %Deck{dbDeck | black_cards: Jason.decode!(dbDeck.black_cards, %{keys: :atoms})}

    end
  end

  def get_decks(ids) do
    dbDecks =
      Deck
      |> where([d], d.id in ^ids)
      |> Repo.all()

    Enum.map(dbDecks, fn deck ->
      if(is_nil(deck)) do
        nil
      else
      %Deck{deck | black_cards: Jason.decode!(deck.black_cards, %{keys: :atoms})}
      end
    end)
  end
  @doc """
  Creates a deck.

  ## Examples

      iex> create_deck(%{field: value})
      {:ok, %Deck{}}

      iex> create_deck(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_deck(attrs \\ %{}) do
    %Deck{}
    |> Deck.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a deck.

  ## Examples

      iex> update_deck(deck, %{field: new_value})
      {:ok, %Deck{}}

      iex> update_deck(deck, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_deck(%Deck{} = deck, attrs) do
    deck
    |> Deck.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a deck.

  ## Examples

      iex> delete_deck(deck)
      {:ok, %Deck{}}

      iex> delete_deck(deck)
      {:error, %Ecto.Changeset{}}

  """
  def delete_deck(%Deck{} = deck) do
    Repo.delete(deck)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking deck changes.

  ## Examples

      iex> change_deck(deck)
      %Ecto.Changeset{data: %Deck{}}

  """
  def change_deck(%Deck{} = deck, attrs \\ %{}) do
    Deck.changeset(deck, attrs)
  end
end
