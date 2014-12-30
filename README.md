tracker_request
==============

tracker_request is an elixir library for dealing with bittorrent tracker requests and responses

# Examples

```elixir
response = TrackerRequest.request torrent, listening_port: 6689, peer_id: generate_peer_id
#example data
# {:ok,
#  %{"info_hash" => <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7>>,
#    "interval" => 3600,
#    "peers" => [%Peer{ip: '0.0.0.0',
#      peer_id: <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7>>,
#      port: 29299},
#     %Peer{ip: '0.0.0.0',
#      peer_id: <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7>>,
#      port: 29299}...]...}}
```

## Install

Add to your mix.exs deps

```elixir
{:tracker_request, "~> 0.0.4"}
```

## Copyright
Copyright (c) 2014-2015 Alexander Ivanov. See [LICENSE](LICENSE) for further details


