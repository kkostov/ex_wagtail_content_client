defmodule ExWagtailContentClient.MixProject do
  use Mix.Project

  @source_url "https://github.com/kkostov/ex_wagtail_content_client"
  @version "0.1.0"

  def project do
    [
      app: :ex_wagtail_content_client,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:html_sanitize_ex, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "Client library for consuming the [Wagtail content API](https://docs.wagtail.org/en/stable/advanced_topics/api/v2/usage.html)"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ex_wagtail_content_client",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"]
    ]
  end
end
