defmodule BirdsAgainstMortalityWeb.LandingPageLive do
  use BirdsAgainstMortalityWeb, :live_view
  alias BirdsAgainstMortality.Cards
  @impl true
  def mount(params, session, socket) do
    newName = params["new_name"]
    user = session["user"]
    user = %{id: user.id, name: (if !is_nil(newName), do: newName, else: user.name)}
    deck_options = Cards.get_sitewide_decks
    default_deck = Enum.find(deck_options, nil, fn deck -> deck.name == "CAH Base Set" end )

    default_deck = if(!is_nil(default_deck)) do
      default_deck.id
    else
      0
    end
    {:ok, assign(socket, user: user, tab: "join", points_to_win: 10, max_players: 7, hand_size: 10, deck_options: deck_options, deck_selections: [default_deck])}
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply,
    redirect(socket,
       to: Routes.landing_page_path(socket, :index, %{new_name: name}), replace: true
     )}
  end

  def handle_event("deck-selection", %{"deck-id" => id} = params, %{assigns: %{deck_selections: selections}} = socket) do
    toSet = Map.has_key?(params, "value")
    {parsed_id, _} = Integer.parse(id)
    selections = if(toSet) do
      [parsed_id | selections]
    else
      Enum.filter(selections, fn id -> id != parsed_id end)
    end

    {:noreply, assign(socket, deck_selections: selections)}
  end

  def handle_event("change-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, tab: tab)}
  end

  def handle_event("start-game", %{"deck_id" => deck_id, "points_to_win" => points_to_win, "max_players" => max_players, "hand_size" => hand_size}, socket) do
    IO.inspect(deck_id)
    {:noreply,
    redirect(socket,
    to: Routes.game_path(socket, :index, %{deck_id: deck_id, points_to_win: points_to_win, max_players: max_players, hand_size: hand_size})
  )}
  end

  def handle_event("join-game", %{"game_id" => game_id}, socket) do
      {:noreply,
      redirect(socket,
        to: Routes.game_path(socket, :index, %{game_id: game_id})
      )}
  end
end
