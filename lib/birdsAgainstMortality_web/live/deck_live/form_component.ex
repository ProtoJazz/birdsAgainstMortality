defmodule BirdsAgainstMortalityWeb.DeckLive.FormComponent do
  use BirdsAgainstMortalityWeb, :live_component

  alias BirdsAgainstMortality.Cards

  @impl true
  def update(%{deck: deck} = assigns, socket) do
    changeset = Cards.change_deck(deck)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"deck" => deck_params}, socket) do
    changeset =
      socket.assigns.deck
      |> Cards.change_deck(deck_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"deck" => deck_params}, socket) do
    save_deck(socket, socket.assigns.action, deck_params)
  end

  defp save_deck(socket, :edit, deck_params) do
    case Cards.update_deck(socket.assigns.deck, deck_params) do
      {:ok, _deck} ->
        {:noreply,
         socket
         |> put_flash(:info, "Deck updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_deck(socket, :new, deck_params) do
    case Cards.create_deck(deck_params) do
      {:ok, _deck} ->
        {:noreply,
         socket
         |> put_flash(:info, "Deck created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
