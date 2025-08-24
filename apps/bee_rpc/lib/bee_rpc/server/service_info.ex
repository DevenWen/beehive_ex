defmodule BeeRpc.Server.ServiceInfo do
  @moduledoc """
  Defines the structure for service information used in service registration and discovery.

  ServiceInfo struct contains:
    - :name - The name of the service (string).
    - :address - The address where the service is hosted (string).
    - :port - The port number on which the service listens (integer).
    - :metadata - Optional metadata about the service (map).
    - :functions - List of functions provided by the service (list of strings).

  functions is a list of function names (as strings) that the service provides.
    - functions: ["function/1", "function/2", ...]
  """

  @type t :: %__MODULE__{
          name: String.t(),
          address: String.t(),
          port: non_neg_integer(),
          metadata: map() | nil,
          functions: [String.t()]
        }

  @enforce_keys [:name, :address, :port, :functions]
  defstruct [
    :name,
    :address,
    :port,
    :metadata,
    :functions
  ]
end
