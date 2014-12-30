defmodule TrackerRequest.Mixfile do
  use Mix.Project

  def project do
    [app: :tracker_request,
     version: "0.0.4",
     elixir: "~> 1.0.0",
     description: "Deal with bittorrent tracker requests and responses",
     package: package,
     deps: deps]
  end

  defp package do
    [ contributors: ["alehander42"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/alehander42/tracker_request"}]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:bencoder, "~> 0.0.7"}]
  end
end
