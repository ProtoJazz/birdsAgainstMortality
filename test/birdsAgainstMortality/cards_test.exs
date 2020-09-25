defmodule BirdsAgainstMortality.CardsTest do
  use BirdsAgainstMortality.DataCase

  alias BirdsAgainstMortality.Cards

  describe "decks" do
    alias BirdsAgainstMortality.Cards.Deck

    @valid_attrs %{black_cards: "some black_cards", white_cards: "some white_cards"}
    @update_attrs %{black_cards: "some updated black_cards", white_cards: "some updated white_cards"}
    @invalid_attrs %{black_cards: nil, white_cards: nil}

    def deck_fixture(attrs \\ %{}) do
      {:ok, deck} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Cards.create_deck()

      deck
    end

    test "list_decks/0 returns all decks" do
      deck = deck_fixture()
      assert Cards.list_decks() == [deck]
    end

    test "get_deck!/1 returns the deck with given id" do
      deck = deck_fixture()
      assert Cards.get_deck!(deck.id) == deck
    end

    test "create_deck/1 with valid data creates a deck" do
      assert {:ok, %Deck{} = deck} = Cards.create_deck(@valid_attrs)
      assert deck.black_cards == "some black_cards"
      assert deck.white_cards == "some white_cards"
    end

    test "create_deck/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cards.create_deck(@invalid_attrs)
    end

    test "update_deck/2 with valid data updates the deck" do
      deck = deck_fixture()
      assert {:ok, %Deck{} = deck} = Cards.update_deck(deck, @update_attrs)
      assert deck.black_cards == "some updated black_cards"
      assert deck.white_cards == "some updated white_cards"
    end

    test "update_deck/2 with invalid data returns error changeset" do
      deck = deck_fixture()
      assert {:error, %Ecto.Changeset{}} = Cards.update_deck(deck, @invalid_attrs)
      assert deck == Cards.get_deck!(deck.id)
    end

    test "delete_deck/1 deletes the deck" do
      deck = deck_fixture()
      assert {:ok, %Deck{}} = Cards.delete_deck(deck)
      assert_raise Ecto.NoResultsError, fn -> Cards.get_deck!(deck.id) end
    end

    test "change_deck/1 returns a deck changeset" do
      deck = deck_fixture()
      assert %Ecto.Changeset{} = Cards.change_deck(deck)
    end
  end
end
