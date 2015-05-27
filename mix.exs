defmodule OpenAperture.OverseerApi.Mixfile do
  use Mix.Project

  def project do
    [app: :openaperture_overseer_api,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: { OpenAperture.OverseerApi, [] },
      applications: [:logger, :openaperture_messaging, :openaperture_manager_api]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:ex_doc, "0.7.3", only: :test},
      {:earmark, "0.1.17", only: :test},  
      {:poison, "~> 1.3.1"},
      {:openaperture_messaging, git: "https://github.com/OpenAperture/messaging.git", ref: "11061d019bab15c4b43425f7cdb50899eef05b45", override: true},
      {:openaperture_manager_api, git: "https://github.com/OpenAperture/manager_api.git", ref: "ae629a4127acceac8a9791c85e5a0d3b67d1ad16", override: true},

      #test dependencies
      {:exvcr, github: "parroty/exvcr", override: true},
      {:meck, "0.8.2", override: true}       
    ]
  end
end
