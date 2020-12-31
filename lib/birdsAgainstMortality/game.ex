defmodule BirdsAgainstMortality.Game do
  alias BirdsAgainstMortality.{Game, State, Cards}
  alias BirdsAgainstMortality.Cards.Deck

  defstruct state: %State{}, deck_ids: nil, points_to_win: 10, hand_size: 10, player_limit: 7

  use GenServer, restart: :transient

  @timeout 600_000

  def start_link(options) do
    GenServer.start_link(__MODULE__, initalize_game(options[:deck_ids], options[:points_to_win], options[:hand_size], options[:max_players]), options)
  end

  defp initalize_game(deck_ids, points_to_win, hand_size, player_limit) do
    %Game{}
    |>load_cards(deck_ids)
    |>setup_options(points_to_win, hand_size, player_limit)
  end

  defp setup_options(game, points_to_win, hand_size, player_limit) do
    game = %Game{ game | points_to_win: points_to_win, hand_size: hand_size, player_limit: player_limit}
    game
  end

  defp load_cards(game, deck_ids) do
    #this will need to be an external ID soon
    %Game{ game |state: %State{game.state | decks: refresh_deck(deck_ids)}, deck_ids: deck_ids}
  end

  def refresh_deck(deck_ids) do
    decks = Cards.get_decks(deck_ids)
    decks = if Enum.count(decks) < 1 do
      [Cards.get_deck!(1)]
    else
      decks
    end
    white_cards = Enum.reduce(decks, [], fn deck, acc ->
    acc ++ deck.white_cards
    end)
    black_cards = Enum.reduce(decks, [], fn deck, acc ->
      acc ++ deck.black_cards
      end)
    full_deck = Deck.shuffle(%Deck{black_cards: black_cards, white_cards: white_cards})
  end

  @impl true
  def init(game) do
    {:ok, game, @timeout}
  end

  @impl true
  def handle_call(:game, _from, game) do
    {:reply, game, game, @timeout}
  end


"""
  @impl true
  def handle_cast({:place, position}, game) do
    {:noreply, Game.place(game, position), @timeout}
  end

  @impl true
  def handle_cast({:jump, destination}, game) do
    {:noreply, Game.jump(game, destination), @timeout}
  end
"""

  @impl true
  def handle_cast({:join, user}, game) do
    {:noreply, Game.join(game, user), @timeout}
  end

  @impl true
  def handle_cast({:start}, game) do
    {:noreply, Game.start(game) |> Game.new_judge, @timeout}
  end

  @impl true
  def handle_cast({:play_card, player, card_index, player_index}, game) do
    {:noreply, Game.play_card(game, player, card_index, player_index), @timeout}
  end

  @impl true
  def handle_cast({:play_cards, player, cards_to_play, player_index}, game) do
    {:noreply, Game.play_cards(game, player, cards_to_play, player_index), @timeout}
  end


  @impl true
  def handle_cast({:judge, player_id}, game) do
    {:noreply, Game.judge(game, player_id) |> Game.new_judge, @timeout}
  end

  def judge(game, player_id) do
    newPlayers = Enum.map(game.state.players, fn player ->
      if(player.id == player_id) do
        %{player | points: (player.points + 1)}
      else
        player
      end
    end)

    round_winning_player = Enum.find(newPlayers, nil, fn player -> player.id == player_id end)
    newState = if !is_nil(round_winning_player) and round_winning_player.points >= game.points_to_win do
      %State{game.state | players: newPlayers, winner: round_winning_player, game_over: true}
    else
      %State{game.state | players: newPlayers}
    end
    %Game{game | state: newState}
  end

  def start(game) do
    if(game.state.judge == nil) do
      {player, index} = Enum.random(Enum.with_index(game.state.players))
      newState = %State{game.state | judge: %{player: player, index: index}}
      %Game{game | state: newState}
    else
      game
    end
  end

  def play_card(game, player, card_index, player_index) do
    currentPlayers = game.state.players
    newPlayers = List.replace_at(currentPlayers, player_index, %{player | cards_in_play: player.cards_in_play ++ [card_index]})
    newState = %State{game.state | players: newPlayers}
    %Game{game | state: newState}
  end

  def play_cards(game, player, cards_to_play, player_index) do
    currentPlayers = game.state.players
    newPlayers = List.replace_at(currentPlayers, player_index, %{player | cards_in_play: cards_to_play})
    newState = %State{game.state | players: newPlayers}
    %Game{game | state: newState}
  end

  def new_judge(game) do
    currentIndex = game.state.judge.index
    newIndex = if (currentIndex + 1) >= Enum.count(game.state.players) do
      0
    else
      currentIndex + 1
    end

    newPlayers = Enum.map(game.state.players, fn player ->
      hand = Enum.filter(
        Enum.with_index(player.hand), fn {card, index} ->
          !Enum.member?(player.cards_in_play, index)
        end) |> Enum.map(fn {card, index} -> card end)

        %{player | hand: hand, cards_in_play: []}
    end)

    player = Enum.at(game.state.players, newIndex)
    decks = game.state.decks
    black_card = List.first(Enum.slice(decks.black_cards, 0..(0)))

    remaining_black_cards = if (Enum.count(decks.black_cards) > 1) do
      Enum.slice(decks.black_cards, 1 .. Enum.count(decks.white_cards))
      else
        deck = refresh_deck(game.deck_ids)
        deck.black_cards
      end
    newState = %State{game.state | judge: %{player: player, index: newIndex}, decks: %{game.state.decks | black_cards: remaining_black_cards}, current_black_card: black_card, players: newPlayers}
    newGame = %Game{game | state: newState}
    if(black_card.draw > 0) do
      Enum.reduce(Enum.with_index(game.state.players), newGame, fn {loop_player, index}, redGame ->
        if(player.id != loop_player.id) do
          deal(redGame, %{player: loop_player, deal_count: black_card.draw , player_index: index})
        else
          redGame
        end
      end)
    else
      newGame
    end
  end
  @impl true
  def handle_cast({:deal, params}, game) do
    {:noreply, Game.deal(game, params), @timeout}
  end
  @impl true
  def handle_info(:timeout, game) do
    {:stop, :normal, game}
  end

  def state(%Game{state: state}) do
    state
  end

  def deal(game, %{player: player, deal_count: deal_count, player_index: index}) do
    decks = game.state.decks
    decks = if(Enum.count(decks.white_cards) < deal_count) do
      deck = refresh_deck(game.deck_ids)
    else
      decks
    end
    cards_to_deal = Enum.slice(decks.white_cards, 0..(deal_count - 1))
    remaining_cards = Enum.slice(decks.white_cards, deal_count.. Enum.count(decks.white_cards))

    newState = %State{game.state | players: List.replace_at(game.state.players, index, %{player | hand: player.hand ++ cards_to_deal}), decks: %{game.state.decks | white_cards: remaining_cards}}
    %Game{game | state: newState}
  end

  @spec join(atom | %{state: atom | %{players: any}}, any) ::
          atom | %{state: atom | %{players: any}}
  def join(game, user) do
    existing_player = Enum.find(game.state.players, nil, fn player -> player.id == user.id end)
      if is_nil(existing_player) do
        newPlayers = game.state.players ++ [%{id: user.id, name: user.name, color: user.color, hand: [], points: 0, cards_in_play: []}]
        newState = %State{game.state | players: newPlayers}
        %Game{game | state: newState}
      else
        game
      end
  end
end
