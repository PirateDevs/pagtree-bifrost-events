defmodule TesseractEmbedded.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesseract_embedded,
      version: "1.2.6",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.13"},
      {:jason, "~> 1.4"},
      {:zot, ">= 0.0.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
