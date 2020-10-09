defmodule BirdsAgainstMortalityWeb.DeckLive.Index do
  use BirdsAgainstMortalityWeb, :live_view

  alias BirdsAgainstMortality.Cards
  alias BirdsAgainstMortality.Cards.Deck

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :decks, list_decks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Deck")
    |> assign(:deck, Cards.get_deck!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Deck")
    |> assign(:deck, %Deck{white_cards: [""], black_cards: [%{text: "", draw: 0, play: 1}]})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Decks")
    |> assign(:deck, nil)
  end

  def handle_event("save-deck", params, socket) do
    white_card_fields = Enum.filter(params, fn {name, _value} ->
      if(String.starts_with?(name, "white_card")) do
        true
      end
      end)

    white_cards = Enum.map(white_card_fields, fn {_, value} -> value end)

    black_card_fields = Enum.filter(params, fn {name, _value} ->
      if(String.starts_with?(name, "black_card")) do
        true
      end
      end)
    black_draw_fields = Enum.filter(params, fn {name, _value} ->
      if(String.starts_with?(name, "black_draw")) do
        true
      end
      end)
    black_play_fields = Enum.filter(params, fn {name, _value} ->
      if(String.starts_with?(name, "black_play")) do
        true
      end
      end)

    black_draws = Enum.map(black_draw_fields, fn {_, value} -> value  end)
    black_plays = Enum.map(black_play_fields, fn {_, value} -> value  end)
    black_cards = Enum.with_index(Enum.map(black_card_fields, fn {_, value} -> value  end))
    |> Enum.map(fn {text, index} -> %{text: text, draw: Enum.at(black_draws, index), play: Enum.at(black_plays, index)} end )
    |> Jason.encode!()
    if(is_nil(socket.assigns.deck.id)) do
      {Cards.create_deck(%{white_cards: white_cards, black_cards: black_cards})}
    else
      {Cards.update_deck(socket.assigns.deck, %{white_cards: white_cards, black_cards: black_cards})}
    end

    {:noreply, socket}
  end

  def handle_event("add-white-card", _, socket) do
    newWhiteCards = socket.assigns.deck.white_cards ++ [""]
    newDeck = %Deck{socket.assigns.deck | white_cards: newWhiteCards}
    {:noreply, assign(socket, deck: newDeck)}
  end

  def handle_event("add-black-card", _, socket) do
    newBlackCards = socket.assigns.deck.black_cards ++ [%{text: "", draw: 0, play: 1}]
    newDeck = %Deck{socket.assigns.deck | black_cards: newBlackCards}
    {:noreply, assign(socket, deck: newDeck)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    deck = Cards.get_deck!(id)
    {:ok, _} = Cards.delete_deck(deck)

    {:noreply, assign(socket, :decks, list_decks())}
  end

  defp list_decks do
    Cards.list_decks()
  end
end
