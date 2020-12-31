defmodule BirdsAgainstMortalityWeb.GameLive do
  use BirdsAgainstMortalityWeb, :live_view
  alias BirdsAgainstMortality.Game
  @default_player %{id: "user.id", name: "user.name", hand: [], points: 0}
  @impl true
  def mount(params, session, socket) do
    user = session["user"]
    {:ok,
     assign(socket, user: user, my_player: @default_player, open_chat: true, my_selected_cards: [])}
  end

  def handle_params(%{"game_id" => game_id} = _params, _uri, socket) do
    if connected?(socket), do: subscribe(game_id)

    socket =
      socket
      |> assign_game(game_id)
      |> assign(posts: [], temporary_assigns: [posts: []])

    {:noreply, socket}
  end

  def handle_params(%{"deck_id" => deck_id, "points_to_win" => points_to_win, "max_players" => max_players, "hand_size" => hand_size} = _params, _uri, socket) do
    deck_ids =
      if(deck_id == "") do
        1
      else
        String.split(deck_id, ",")
        |> Enum.map(fn string_id ->
          {id, _} = Integer.parse(string_id)
          id
        end)

      end

    points_to_win =
      if(points_to_win == "") do
        10
      else
        {points, _} = Integer.parse(points_to_win)
        points
      end

      max_players =
      if(max_players == "") do
        7
      else
        {players, _} = Integer.parse(max_players)
        players
      end
      hand_size =
      if(hand_size == "") do
        10
      else
        {hand, _} = Integer.parse(hand_size)
        hand
      end


    game_id = generate_game_id()
    start_game_server(game_id, deck_ids, points_to_win, max_players, hand_size)

    {:noreply,
     push_redirect(
       socket,
       to: Routes.game_path(socket, :index, game_id: game_id)
     )}
  end

  def start_game_server(game_id, deck_ids \\ [1], points_to_win \\ 10, max_players \\ 7, hand_size \\ 10) do
    IO.puts("DING DIGN")
    {:ok, _pid} =
      DynamicSupervisor.start_child(
        BirdsAgainstMortality.GameSupervisor,
        {Game, name: via_tuple(game_id), deck_ids: deck_ids, points_to_win: points_to_win, max_players: max_players, hand_size: hand_size}
      )
  end

  @spec generate_game_id :: binary
  def generate_game_id() do
    ?a..?z
    |> Enum.take_random(6)
    |> List.to_string()
  end

  def handle_params(_params, _uri, socket) do
    game_id = generate_game_id()
    start_game_server(game_id)

    {:noreply,
     push_redirect(
       socket,
       to: Routes.game_path(socket, :index, game_id: game_id)
     )}
  end

  defp via_tuple(name) do
    {:via, Registry, {BirdsAgainstMortality.GameRegistry, name}}
  end

  defp assign_game(socket, game_id) do
    socket
    |> assign(game_id: game_id)
    |> assign_game()
  end

  defp draw_if_needed(
         %{assigns: %{game_id: game_id, user: user, game: game, state: state}} = socket
       ) do
    # my_player = Enum.find(state.players, nil, fn player -> player.id == user.id end)

    my_player = Enum.find(game.state.players, nil, fn l_player -> l_player.id == user.id end)

    if !is_nil(my_player) and Enum.count(my_player.hand) < game.hand_size do
      {my_player, my_player_index} =
        Enum.find(Enum.with_index(game.state.players), nil, fn {l_player, _index} ->
          l_player.id == user.id
        end)

      :ok =
        GenServer.cast(
          via_tuple(game_id),
          {:deal,
           %{
             player: my_player,
             player_index: my_player_index,
             deal_count: game.hand_size - Enum.count(my_player.hand)
           }}
        )

      :ok = Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, game_id, :update)
      socket
    else
      socket
    end
  end

  defp assign_game(%{assigns: %{game_id: game_id, user: user}} = socket) do
    game = GenServer.call(via_tuple(game_id), :game)
    state = Game.state(game)

    socket
    |> assign(
      game: game,
      state: state,
      my_player: Enum.find(state.players, @default_player, fn player -> user.id == player.id end)
    )
    |> draw_if_needed
  end

  defp join_game(%{assigns: %{game_id: game_id, user: user}} = socket) do
    :ok = GenServer.cast(via_tuple(game_id), {:join, user})
    :ok = Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, game_id, :update)
    socket
  end

  def handle_event("join-game", _params, socket) do
    socket =
      socket
      |> join_game()

    {:noreply, socket}
  end

  def handle_event("start-game", _params, socket) do
    :ok = GenServer.cast(via_tuple(socket.assigns.game_id), {:start})
    :ok = Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, socket.assigns.game_id, :update)
    {:noreply, socket}
  end

  def handle_event("send-message", %{"message" => message}, socket) do
    create_post(%{user_name: socket.assigns.user.name, body: message}, socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply,
     push_redirect(socket, to: Routes.page_path(socket, :index, %{new_name: name}), replace: true)}
  end

  def handle_event("judge-card", %{"player-id" => player_id, "index" => _card_index}, socket) do
    if(am_judge(socket)) do
      :ok = GenServer.cast(via_tuple(socket.assigns.game_id), {:judge, player_id})

      :ok =
        Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, socket.assigns.game_id, :update)
    end

    {:noreply, socket}
  end

  def handle_event("select-card", %{"index" => index}, socket) do
    {parsedIndex, _} = Integer.parse(index)
    selected_cards = socket.assigns.my_selected_cards

    plays =
      if(!is_nil(socket.assigns.state.current_black_card)) do
        {parsed_plays, _} = Integer.parse(socket.assigns.state.current_black_card.play)
        parsed_plays
      else
        0
      end

    plays = plays - Enum.count(selected_cards)

    socket =
      if !is_nil(socket.assigns.my_player.id == socket.assigns.user.id) and !am_judge(socket) and
           !is_nil(socket.assigns.state.current_black_card) do
        selecting = !Enum.member?(selected_cards, parsedIndex)
        if selecting do
          if(plays > 0) do
            select_card(socket, parsedIndex)
          else
            socket
          end
        else
          unselect_card(socket, parsedIndex)
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("play-cards", params,  socket) do
    game = socket.assigns.game
    user = socket.assigns.user
    cards_to_play = socket.assigns.my_selected_cards
    if (socket.assigns.my_player.id == socket.assigns.user.id) and !am_judge(socket) and
        (!is_nil(socket.assigns.state.current_black_card)) do
    {my_player, my_player_index} = Enum.find(Enum.with_index(game.state.players), nil, fn {l_player, _index} ->  l_player.id == user.id end)
    :ok =
      GenServer.cast(
        via_tuple(socket.assigns.game_id),
        {:play_cards, my_player, cards_to_play, my_player_index}
      )

    :ok =
      Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, socket.assigns.game_id, :update)

      {:noreply, assign(socket, my_selected_cards: [])}
end

  end

  def handle_event("play-card", %{"index" => index}, socket) do
    {parsedIndex, _} = Integer.parse(index)
    game = socket.assigns.game
    user = socket.assigns.user

    plays =
      if(!is_nil(socket.assigns.state.current_black_card)) do
        {parsed_plays, _} = Integer.parse(socket.assigns.state.current_black_card.play)
        parsed_plays
      else
        0
      end

    if socket.assigns.my_player.id == socket.assigns.user.id and !am_judge(socket) and
         (!is_nil(socket.assigns.state.current_black_card) and
            plays > Enum.count(socket.assigns.my_player.cards_in_play)) do
      {my_player, my_player_index} =
        Enum.find(Enum.with_index(game.state.players), nil, fn {l_player, _index} ->
          l_player.id == user.id
        end)

      :ok =
        GenServer.cast(
          via_tuple(socket.assigns.game_id),
          {:play_card, my_player, parsedIndex, my_player_index}
        )

      :ok =
        Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, socket.assigns.game_id, :update)
    end

    {:noreply, socket}
  end

  def am_judge(%{assigns: %{state: state, my_player: player}}) do
    !is_nil(state.judge) and state.judge.player.id == player.id
  end

  def am_judge(state, player) do
    !is_nil(state.judge) and state.judge.player.id == player.id
  end

  # Could go in a context or something
  def subscribe(game_id) do
    Phoenix.PubSub.subscribe(BirdsAgainstMortality.PubSub, game_id)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast(post, event, game_id) do
    Phoenix.PubSub.broadcast(BirdsAgainstMortality.PubSub, game_id, {event, post})
    {:ok, post}
  end

  def select_card(%{assigns: %{my_selected_cards: selected_cards}} = socket, index) do
    new_plays = selected_cards ++ [index]

    socket
    |> assign(my_selected_cards: new_plays)
  end

  def unselect_card(%{assigns: %{my_selected_cards: selected_cards}} = socket, index) do
    new_plays = Enum.filter(selected_cards, fn card -> card != index end)

    socket
    |> assign(my_selected_cards: new_plays)
  end


  def create_post(attrs, game_id) do
    attrs
    |> broadcast(:post_created, game_id)
  end

  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
  end
end
