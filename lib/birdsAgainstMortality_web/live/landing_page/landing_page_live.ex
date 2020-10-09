defmodule BirdsAgainstMortalityWeb.LandingPageLive do
  use BirdsAgainstMortalityWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    newName = params["new_name"]
    user = session["user"]
    user = %{id: user.id, name: (if !is_nil(newName), do: newName, else: user.name)}
    {:ok, assign(socket, user: user, tab: "join", points_to_win: 10, max_players: 7, hand_size: 10)}
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply,
    redirect(socket,
       to: Routes.landing_page_path(socket, :index, %{new_name: name}), replace: true
     )}
  end

  def handle_event("change-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, tab: tab)}
  end

  def handle_event("start-game", %{"deck_id" => deck_id, "points_to_win" => points_to_win, "max_players" => max_players, "hand_size" => hand_size}, socket) do
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
