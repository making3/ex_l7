defmodule ExL7.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_l7,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:timex, "~> 3.1"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description() do
    "Elixir HL7 quick parsing, mapping, and manipulation library."
  end

  defp package() do
    [
      maintainers: ["Matthew King"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/making3/ex_l7"}
    ]
  end
end
