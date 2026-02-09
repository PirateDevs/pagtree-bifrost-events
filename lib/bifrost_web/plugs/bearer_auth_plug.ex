defmodule BifrostWeb.BearerAuthPlug do
  @moduledoc ~S"""
  Bearer authentication plug.

      plug BifrostWeb.BearerAuthPlug, authorized_by: Pag3.Bifrost.Heimdall

  This plug protects routes by requiring a **Bearer** token that will
  be validated by an **Authorizer** module. Such module must implement
  a `authorized?/1` function, which receives the bearer token as its
  only argument.
  """

  use Plug.Builder

  @impl Plug
  def init(opts), do: Keyword.fetch!(opts, :authorized_by)

  @impl Plug
  def call(%Plug.Conn{} = conn, authorizer) do
    with {:a, {:ok, {:bearer, token}}} <- {:a, get_req_credentials(conn)},
         {:b, true} <- {:b, authorizer.authorized?(token)} do
      conn
    else
      {:a, _}     -> halt(send_problem(conn, 401, reason: :authentication_required))
      {:b, false} -> halt(send_problem(conn, 401, reason: :incorrect_credentials))
    end
  end

  #
  #   PRIVATE
  #

  defp send_problem(conn, status, reason: :authentication_required) do
    json = Jason.encode!(%{
      "status" => 401,
      "type" => "tag:authentication-required",
      "title" => "Authentication Required",
      "detail" => "The requested resource requires authentication.",
      "requestId" => Map.get(conn.assigns, :request_id)
    })

    conn
    |> put_resp_content_type("application/problem+json")
    |> send_resp(status, json)
  end

  defp send_problem(conn, status, reason: :incorrect_credentials) do
    json = Jason.encode!(%{
      "status" => 401,
      "type" => "tag:incorrect-credentials",
      "title" => "Incorrect Credentials",
      "detail" => "The provided credentials are incorrect or invalid.",
      "requestId" => Map.get(conn.assigns, :request_id)
    })

    conn
    |> put_resp_content_type("application/problem+json")
    |> send_resp(status, json)
  end

  defp get_req_credentials(conn) do
    case get_req_authorization_header(conn) do
      {:ok, {:bearer, token}} -> {:ok, {:bearer, token}}
      {:ok, {:basic, nil, token}} -> {:ok, {:bearer, token}}
      {:ok, {:basic, token, nil}} -> {:ok, {:bearer, token}}
      {:ok, {:basic, user, password}} -> {:ok, {:basic, user, password}}
      _ -> {:error, :missing}
    end
  end

  defp get_req_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      [] -> {:error, :missing}
      ["" | _] -> {:error, :missing}
      [value | _] -> parse_authorization_header(value)
    end
  end

  defp parse_authorization_header("Bearer " <> token) do
    case String.trim(token) do
      <<_, _::binary>> = token -> {:ok, {:bearer, token}}
      _ -> {:error, :missing}
    end
  end

  defp parse_authorization_header("Basic " <> token = header_value) do
    parts =
      token
      |> String.trim()
      |> Base.decode64!()
      |> String.split(":", parts: 2)
      |> Enum.map(&nullify/1)

    case parts do
      [nil, nil] -> {:error, :missing}
      [username, password] -> {:ok, {:basic, username, password}}
      _ -> {:error, :missing}
    end
  rescue
    _ -> {:error, {:invalid, header_value}}
  end

  defp parse_authorization_header(header_value),
    do: {:error, {:invalid, header_value}}

  defp nullify(nil), do: nil
  defp nullify(<<>>), do: nil
  defp nullify(<<_, _::binary>> = str), do: if(String.trim(str) == "", do: nil, else: str)
end
