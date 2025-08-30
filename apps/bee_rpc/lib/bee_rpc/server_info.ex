defmodule BeeRpc.ServerInfo do
  @moduledoc """
  Defines the structure for service information used in service registration and discovery.

  ServerInfo struct contains:
    - :service - The name of the service (string).
    - :host - The address where the service is hosted (string).
    - :port - The port number on which the service listens (integer).
    - :metadata - Optional metadata about the service (map).
    - :functions - List of functions provided by the service (list of strings).

  functions is a list of function names (as strings) that the service provides.
    - functions: ["function/1", "function/2", ...]
  """

  @type t :: %__MODULE__{
          service: String.t(),
          host: String.t(),
          port: non_neg_integer(),
          metadata: map() | nil,
          functions: [String.t()]
        }

  @enforce_keys [:service, :host, :port, :functions]
  defstruct [
    :service,
    :host,
    :port,
    :metadata,
    :functions,
    # version to store etcd
    :version
  ]

  def from_json_str(json_str, version \\ nil) do
    case JSON.decode(json_str) do
      {:ok, map} when is_map(map) ->
        result = %__MODULE__{
          service: map["service"],
          host: map["host"],
          port: map["port"],
          metadata: map["metadata"],
          functions: map["functions"],
          version: version
        }

        {:ok, result}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
