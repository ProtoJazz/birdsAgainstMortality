defmodule BirdsAgainstMortality.Game do
  alias BirdsAgainstMortality.{Game, State, Cards}
  alias BirdsAgainstMortality.Cards.Deck

  defstruct state: %State{}, deck_id: nil, points_to_win: 10, hand_size: 10, player_limit: 7

  use GenServer, restart: :transient

  @timeout 600_000

  def start_link(options) do
    GenServer.start_link(__MODULE__, initalize_game(options[:deck_id]), options)
  end

  defp initalize_game(deck_id) do
    %Game{}
    |>load_cards(deck_id)
  end

  defp load_cards(game, deck_id) do
    #this will need to be an external ID soon
    deck = Cards.get_deck(deck_id)
    deck = if is_nil(deck) do
      Cards.get_deck!(1)
    else
      deck
    end
    %Game{ game |state: %State{game.state | decks: Deck.shuffle(deck)}, deck_id: deck_id}
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
    newState = %State{game.state | players: newPlayers}
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
    IO.puts("DIASDLKAHSDLKASHD")
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

    remaining_cards = if (Enum.count(decks.black_cards) > 1) do
      IO.puts("SHRINKAGE")
      Enum.slice(decks.black_cards, 1 .. Enum.count(decks.white_cards))
      else
        deck = Cards.get_deck!(game.deck_id)
        deck = Deck.shuffle(deck)
        deck.black_cards
      end
    IO.puts("NEW BLACK")
    IO.inspect(black_card)
    IO.inspect(remaining_cards)
    newState = %State{game.state | judge: %{player: player, index: newIndex}, decks: %{game.state.decks | black_cards: remaining_cards}, current_black_card: black_card, players: newPlayers}
    %Game{game | state: newState}
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
      deck = Cards.get_deck!(game.deck_id)
      Deck.shuffle(deck)
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
