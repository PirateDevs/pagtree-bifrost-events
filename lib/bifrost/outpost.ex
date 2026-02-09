defmodule Bifrost.Outpost do
  @moduledoc ~S"""
  Bifrost outpost generator.

  Define a module representing your outpost:

      defmodule Pag3.Bifrost do
        use Bifrost.Outpost, otp_app: :pag3
      end

  Then add the configurations for the outpost:

      config :pag3, Pag3.Bifrost,
        enabled: true,
        secret: System.fetch_env!("BIFROST_SECRET_KEY")

  """

  @doc ~S"""
  """
  defmacro __using__(opts) do
    {otp_app, opts} = Keyword.pop!(opts, :otp_app)

    for {key, _} <- opts,
        do: raise(ArgumentError, "unknown option #{inspect(key)}")

    caller = __CALLER__.module
    heimdall = Module.concat([caller, "Heimdall"])

    quote do
      @moduledoc """
      Defines the #{unquote(m(caller))} Bifrost outpost.
      """

      defmodule unquote(heimdall) do
        @moduledoc ~S"""
        The Bifrost's guardian.
        """

        import Req.Request, only: [merge_options: 2]

        @doc ~S"""
        Heimdall will give His blessing to the given outgoing request,
        adding the necessary authorization headers to prove that He
        authorized it.
        """
        @spec authorize(req) :: req
              when req: Req.Request.t()

        def authorize(%Req.Request{} = req),
          do: merge_options(req, auth: {:bearer, config!(:secret)})

        @doc ~S"""
        Heimdall will stare the given token for a while, eventually
        coming to the conclusion of whether or not this is a token He
        recognizes and trusts. Will return `false` if the Bifrost
        outpost is disabled.
        """
        @spec authorized?(bearer_token) :: boolean
              when bearer_token: String.t()

        def authorized?(bearer_token)
            when is_binary(bearer_token),
            do: config!(:enabled) == true and bearer_token == config!(:secret)

        unquote(config_fn(otp_app, caller))
      end

      @doc ~S"""
      Returns `true` if Bifrost's inter-service communication is
      enabled for this outpost.
      """
      @spec enabled?() :: boolean

      def enabled?, do: config!(:enabled) == true

      unquote(config_fn(otp_app, caller))
    end
  end

  #
  #   PRIVATE
  #

  defp config_fn(otp_app, caller) do
    quote do
      defp config!(key) when is_atom(key) do
        with {:a, {:ok, [{_, _} | _] = config}} <- {:a, Application.fetch_env(unquote(otp_app), unquote(caller))},
             {:b, {:ok, value}} when not is_nil(value) <- {:b, Keyword.fetch(config, key)} do
          value
        else
          {:a, {:ok, _}}   -> raise("The Bifrost configuration for #{unquote(m(caller))} must be a keyword list")
          {:a, :error}     -> raise("The Bifrost configuration for #{unquote(m(caller))} is missing")
          {:b, {:ok, nil}} -> raise("The Bifrost configuration :#{key} for #{unquote(m(caller))} has no value (nil)")
          {:b, :error}     -> raise("The Bifrost configuration :#{key} for #{unquote(m(caller))} is missing")
        end
      end
    end
  end

  # [m]odule true name
  defp m(mod) do
    mod
    |> to_string()
    |> String.replace("Elixir.", "")
  end
end
