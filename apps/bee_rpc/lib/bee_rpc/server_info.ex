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
    :functions
  ]
end
