defmodule BirdsAgainstMortalityWeb.LandingPageLive do
  use BirdsAgainstMortalityWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    newName = params["new_name"]
    user = session["user"]
    user = %{id: user.id, name: (if !is_nil(newName), do: newName, else: user.name)}
    {:ok, assign(socket, user: user)}
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply,
    redirect(socket,
       to: Routes.landing_page_path(socket, :index, %{new_name: name}), replace: true
     )}
  end

  def handle_event("join-game", %{"game_id" => game_id, "deck_id" => deck_id}, socket) do
    if  game_id == "" do

    {:noreply,
    redirect(socket,
       to: Routes.game_path(socket, :index, %{deck_id: deck_id})
     )}
    else
      {:noreply,
      redirect(socket,
        to: Routes.game_path(socket, :index, %{game_id: game_id})
      )}
    end
  end
end
