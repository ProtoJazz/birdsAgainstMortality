defmodule BirdsAgainstMortalityWeb.DeckLiveTest do
  use BirdsAgainstMortalityWeb.ConnCase

  import Phoenix.LiveViewTest

  alias BirdsAgainstMortality.Cards

  @create_attrs %{black_cards: "some black_cards", white_cards: "some white_cards"}
  @update_attrs %{black_cards: "some updated black_cards", white_cards: "some updated white_cards"}
  @invalid_attrs %{black_cards: nil, white_cards: nil}

  defp fixture(:deck) do
    {:ok, deck} = Cards.create_deck(@create_attrs)
    deck
  end

  defp create_deck(_) do
    deck = fixture(:deck)
    %{deck: deck}
  end

  describe "Index" do
    setup [:create_deck]

    test "lists all decks", %{conn: conn, deck: deck} do
      {:ok, _index_live, html} = live(conn, Routes.deck_index_path(conn, :index))

      assert html =~ "Listing Decks"
      assert html =~ deck.black_cards
    end

    test "saves new deck", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.deck_index_path(conn, :index))

      assert index_live |> element("a", "New Deck") |> render_click() =~
               "New Deck"

      assert_patch(index_live, Routes.deck_index_path(conn, :new))

      assert index_live
             |> form("#deck-form", deck: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#deck-form", deck: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.deck_index_path(conn, :index))

      assert html =~ "Deck created successfully"
      assert html =~ "some black_cards"
    end

    test "updates deck in listing", %{conn: conn, deck: deck} do
      {:ok, index_live, _html} = live(conn, Routes.deck_index_path(conn, :index))

      assert index_live |> element("#deck-#{deck.id} a", "Edit") |> render_click() =~
               "Edit Deck"

      assert_patch(index_live, Routes.deck_index_path(conn, :edit, deck))

      assert index_live
             |> form("#deck-form", deck: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#deck-form", deck: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.deck_index_path(conn, :index))

      assert html =~ "Deck updated successfully"
      assert html =~ "some updated black_cards"
    end

    test "deletes deck in listing", %{conn: conn, deck: deck} do
      {:ok, index_live, _html} = live(conn, Routes.deck_index_path(conn, :index))

      assert index_live |> element("#deck-#{deck.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#deck-#{deck.id}")
    end
  end

  describe "Show" do
    setup [:create_deck]

    test "displays deck", %{conn: conn, deck: deck} do
      {:ok, _show_live, html} = live(conn, Routes.deck_show_path(conn, :show, deck))

      assert html =~ "Show Deck"
      assert html =~ deck.black_cards
    end

    test "updates deck within modal", %{conn: conn, deck: deck} do
      {:ok, show_live, _html} = live(conn, Routes.deck_show_path(conn, :show, deck))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Deck"

      assert_patch(show_live, Routes.deck_show_path(conn, :edit, deck))

      assert show_live
             |> form("#deck-form", deck: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#deck-form", deck: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.deck_show_path(conn, :show, deck))

      assert html =~ "Deck updated successfully"
      assert html =~ "some updated black_cards"
    end
  end
end
