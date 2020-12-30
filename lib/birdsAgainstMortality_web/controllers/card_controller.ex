defmodule BirdsAgainstMortalityWeb.CardController do
  use BirdsAgainstMortalityWeb, :controller
  plug BirdsAgainstMortalityWeb.Plugs.Auth when action in [:new]

  alias BirdsAgainstMortality.Cards
  alias BirdsAgainstMortality.Cards.Deck

def new(conn, data) do
  Enum.each(data, fn dpack ->
    {_id, pack} = dpack
    blackData = pack["black"]
    whiteData = pack["white"]

    black_cards = Enum.map(blackData, fn bd ->
      %{text: bd["text"], draw: 0, play: bd["pick"]}
    end)  |> Jason.encode!()
    white_cards = Enum.map(whiteData, fn wd ->
      "#{wd["text"]}"
    end)
    res = Cards.create_deck(%{white_cards: white_cards, black_cards: black_cards, official: pack["official"], name: pack["name"], sitewide: true})
    IO.inspect(res)
end)
  json(conn, "complete")
end

end
