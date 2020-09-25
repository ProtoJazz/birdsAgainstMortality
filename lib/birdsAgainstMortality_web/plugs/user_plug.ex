defmodule BirdsAgainstMortalityWeb.Plugs.User do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{params: %{"new_name" => newName}} = conn, _opts) do
      existingUser = get_session(conn, :user)

      if is_nil(existingUser) do
        conn
        |> put_session(:user, %{id: UUID.uuid1(), name: newName, color: get_color()})
      else
        newConn = conn
        |> put_session(:user, %{existingUser | name: newName})

        IO.inspect(get_session(newConn, :user))
        newConn
      end
  end
  def call(conn, _default) do
    if is_nil(get_session(conn, :user)) do
      conn
      |> put_session(:user, %{id: UUID.uuid1(), name: "User McUserface", color: get_color()})
    else
      conn
    end
  end

  def get_color() do
    :random.seed(:erlang.now)
    colors = ["red", "orange", "yellow", "olive", "green", "teal", "blue", "violet", "purple", "pink"]
    Enum.random(colors)
  end
end
