defmodule Bifrost.Heimdall do
  @moduledoc ~S"""
  Bifrost API's guardian.
  """

  import Plug.Conn
  import Req.Request, only: [merge_options: 2]

  @doc ~S"""
  Creates a Heimdall module for the given otp app.

      defmodule MyApp.Bifrost do
        use Bifrost.Heimdall, otp_app: :my_app
        # ...
      end

  """
  defmacro __using__(otp_app: otp_app) do
    quote do
      @behaviour Plug

      @impl Plug
      def init(opts), do: unquote(__MODULE__).init(opts, unquote(otp_app))

      @impl Plug
      def call(conn, opts), do: unquote(__MODULE__).call(conn, opts, unquote(otp_app))

      @doc ~S"""
      Authorizes an outgoing request to interact with Bifrost's API.
      """
      @spec authorize(req) :: req
            when req: Req.Request.t()

      def authorize(req), do: unquote(__MODULE__).authorize(req, unquote(otp_app))

      @doc ~S"""
      Returns true if the given secret matches the configured secret
      and Bifrost is enabled.
      """
      @spec authorized?(secret) :: boolean
            when secret: String.t()

      def authorized?(secret), do: unquote(__MODULE__).authorized?(secret, unquote(otp_app))

      @doc ~S"""
      Returns true if Bifrost is enabled for this otp app.
      """
      @spec enabled?() :: boolean

      def enabled?, do: unquote(__MODULE__).enabled?(unquote(otp_app))
    end
  end

  @doc ~S"""
  Authorizes an outgoing request to interact with Bifrost's API.
  """
  @spec authorize(req, otp_app) :: req
        when req: Req.Request.t(),
             otp_app: atom

  def authorize(req, otp_app), do: merge_options(req, auth: {:bearer, config!(otp_app, :secret)})

  @doc ~S"""
  Returns true if the given secret matches the configured secret and
  Bifrost is enabled for the given otp app.
  """
  @spec authorized?(secret, otp_app) :: boolean
        when secret: String.t(),
             otp_app: atom

  def authorized?(secret, otp_app), do: enabled?(otp_app) and config!(otp_app, :secret) == secret

  @doc ~S"""
  Checks whether Bifrost is enabled for the given otp app.
  """
  @spec enabled?(otp_app) :: boolean
        when otp_app: atom

  def enabled?(otp_app), do: config(otp_app, :enabled, false) == true

  #
  #   PLUG CALLBACKS
  #

  @doc false
  def init(_, _), do: []

  @doc false
  def call(conn, _, otp_app) do
    with {:ok, {:bearer, key}} <- credentials_from_authorization_header(conn),
         true <- authorized?(key, otp_app) do
      conn
    else
      _ -> halt(send_resp(conn, 401, ""))
    end
  end

  #
  #   PRIVATE
  #

  defp config!(otp_app, key) do
    with nil <- config(otp_app, key),
         do: raise("missing Bifrost configuration #{inspect(key)}")
  end

  defp config(otp_app, key, default \\ nil) do
    otp_app
    |> Application.get_env(Bifrost, [])
    |> Keyword.get(key, default)
  end

  defp credentials_from_authorization_header(conn) do
    case get_req_authorization_header(conn) do
      {:ok, {:bearer, token}} -> {:ok, {:bearer, token}}
      {:ok, {:basic, nil, token}} -> {:ok, {:bearer, token}}
      {:ok, {:basic, user, password}} -> {:ok, {:basic, user, password}}
      _ -> {:error, :missing}
    end
  end

  def get_req_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      [] -> {:error, :missing}
      [""] -> {:error, :missing}
      [value] -> parse_authorization_header(value)
    end
  end

  defp parse_authorization_header("Bearer " <> token) do
    case String.trim(token) do
      <<_, _::binary>> = token -> {:ok, {:bearer, token}}
      _ -> {:error, :missing}
    end
  end

  defp parse_authorization_header("Basic " <> credentials = header_value) do
    parts =
      credentials
      |> String.trim()
      |> Base.decode64!()
      |> String.split(":")
      |> Enum.map(&nullify/1)

    case parts do
      [nil, nil] -> {:error, :missing}
      [username, password] -> {:ok, {:basic, username, password}}
      _ -> {:error, :missing}
    end
  rescue
    _ -> {:error, {:invalid, header_value}}
  end

  defp parse_authorization_header(header_value), do: {:error, {:invalid, header_value}}

  defp nullify(nil), do: nil
  defp nullify(<<_::binary>> = str), do: with("" <- String.trim(str), do: nil)
end
