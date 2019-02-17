defmodule BattleshipWeb.Plugs.FetchSession do

  import Plug.Conn

  def init(args), do: args

  def call(conn, _args), do: assign(conn, :current_user, "TODO")

end
