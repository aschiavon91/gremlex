defmodule Gremlex.MixProject do
  use Mix.Project

  def project do
    [
      app: :gremlex,
      version: "0.3.3",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/Revmaker/gremlex",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        # The main page in the docs
        main: "Gremlex",
        logo: "logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gremlex.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:confex, "~> 3.5"},
      {:uuid, "~> 1.1"},
      {:poolboy, "~> 1.5"},
      {:socket, "~> 0.3"},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:mock, "~> 0.3", only: :test},
      {:excoveralls, "~> 0.14.4", only: :test},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end

  defp description do
    "An Elixir client for Gremlin (Apache TinkerPop™), a simple to use library for creating Gremlin queries."
  end

  defp package() do
    [
      name: "gremlex",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Revmaker/gremlex"}
    ]
  end
end
