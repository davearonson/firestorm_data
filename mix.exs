defmodule FirestormData.Mixfile do
  use Mix.Project

  def project do
    [
      app: :firestorm_data,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      "test": ["ecto.drop --quiet",
               "ecto.create --quiet",
               "ecto.migrate",
               "test"]
    ]
  end
  
  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :postgrex],
     mod: {FirestormData, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1.4"},
      {:postgrex, "~> 0.11"}
    ]
  end
end
