defmodule BifrostCommons.MixProject do
  use Mix.Project

  def project do
    [
      app: :bifrost_events,
      version: "1.0.7",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.13"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:zot, ">= 0.0.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
