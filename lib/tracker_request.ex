defmodule TrackerRequest do

  @flag_compact    "true"

  @spec remaining(Map.t) :: Integer
  defp remaining(torrent) do
    if "length" in Map.keys torrent do
      torrent["info"]["length"]
    else
      Enum.reduce torrent["info"]["files"], 0, fn (f, acc) ->
        acc + f["length"]
      end
    end
  end

  def sha_sum(binary) do
    :crypto.hash(:sha, binary)
  end

  @spec info_hash(Map.t) :: binary
  defp info_hash(torrent) do
    torrent["info"] |> Bencoder.encode |> sha_sum
  end

  @spec generate_query(Map.t, Keyword.t) :: String
  defp generate_query(torrent, client) do

    q = %{
      "port"       => to_string(client[:listening_port]),
      "info_hash"  => client[:info_hash],
      "uploaded"   => 0,
      "event"      => "started",
      "left"       => to_string(remaining(torrent)),
      "downloaded" => 0,
      "compact"    => @flag_compact,
      "peer_id"    => client[:peer_id]
    } |> URI.encode_query

    s = "#{torrent["announce"]}?#{q}"
    IO.puts s
    s
  end

  @spec request(Map.t, Keyword.t) :: { :ok, Keyword.t } | { :error, term }
  def request(torrent, [listening_port: listening_port, peer_id: peer_id]) do
    client = [peer_id: peer_id, info_hash: info_hash(torrent), listening_port: listening_port]
    {status, body}  = torrent |> generate_query(client) |> String.to_char_list |> get_body
    if status == :ok do
      data = Bencoder.decode(body)
      if Map.has_key?(data, "failure reason") do
        {:error, String.to_atom(data["failure reason"])}
      else
        client = data
        |> Map.put("info_hash", client[:info_hash])
        |> Map.update!("peers", &parse_peer_response/1)
        {:ok, client}
      end
    else
      {:error, body}
    end
  end

  @spec get_body(binary) :: {:ok, binary} | {:error, term}
  defp get_body(query) do
    { ok, {_, _, body} } = :httpc.request(:get, { query, []}, [], [])
    if ok == :ok do
      {:ok, body |> :binary.list_to_bin}
    else
      {:error, :http}
    end
  end

  defp parse_peer_response(data) when is_binary(data) do
    Enum.chunk(data, 6).map(&analyze/1)
  end

  defp parse_peer_response(data) when is_list(data) do
    Enum.map data, fn (a) ->
      %Peer{ ip: String.to_char_list(a["ip"]), port: a["port"], peer_id: Map.get(a, "peer id", "") }
    end
  end

  defp analyze(data) do
    << ip0  :: 8-integer-big-unsigned, ip1 :: 8-integer-big-unsigned,
       ip2  :: 8-integer-big-unsigned, ip3 :: 8-integer-big-unsigned,
       port :: 16-integer-big-unsigned >> = data
    %Peer{ ip: "#{ip0}.#{ip1}.#{ip2}.#{ip3}", port: port, peer_id: nil }
  end
end
