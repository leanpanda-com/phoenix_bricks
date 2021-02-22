defmodule PhoenixBricks.MixProject do
  use Mix.Project

  @version "0.1.1"
  @elixir_requirements "~> 1.11"

  def project do
    [
      app: :phoenix_bricks,
      deps: deps(),
      description: description(),
      dialyzer: [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}],
      docs: docs(),
      elixir: @elixir_requirements,
      package: package(),
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/davidlibrera/phoenix_bricks",
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["David Librera"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/davidlibrera/phoenix_bricks"},
      files: ~w(lib LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.4"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Provide simple modules with common method for pure CRUD PhoenixLiveView
    applications.
    """
  end

  defp docs do
    [
      source_ref: "v#{@version}"
    ]
  end
end
