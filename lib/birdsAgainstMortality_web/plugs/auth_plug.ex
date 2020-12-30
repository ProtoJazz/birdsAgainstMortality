defmodule BirdsAgainstMortalityWeb.Plugs.Auth do
  import Plug.BasicAuth
#Note that we fetch an opt that is used in the call/2 function
def init(_opts) do
  end
def call(conn, _repo) do
    creds = Application.get_env(:birdsAgainstMortality, :basic_auth)
    IO.inspect(creds)
    basic_auth(conn, creds)
  end


end
