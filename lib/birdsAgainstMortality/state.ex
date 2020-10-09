defmodule BirdsAgainstMortality.State do

  defstruct players: [],
            judge: nil,
            decks: %{},
            round_ends: nil,
            current_black_card: nil,
            game_over: false,
            winner: nil
end
