defmodule BirdsAgainstMortalityWeb.ChatComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <ul>
      <%= for message <- @messages do %>
        <li class="<%= if message.user_name == @user.name do "my-post" end %>">
          <%= message.user_name %>: <%= message.body %>
        </li>
      <% end %>
    </ul>

    <form class="ui form chat-input" phx-submit="send-message">
      <label for="message">Message:</label><br>
      <input type="text" id="message" name="message" value=""><br>
      <input class="ui button submit" type="submit" value="Submit">
    </form>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
