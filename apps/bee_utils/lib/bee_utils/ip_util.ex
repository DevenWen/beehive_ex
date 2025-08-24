defmodule BeeUtils.IpUtil do
  @doc """
  get the IP address of eth0 interface, if not found return the first non-loopback IP
  """
  def get_ip() do
    {:ok, ifs} = :inet.getifaddrs()

    ips =
      for {ifname, opts} <- ifs,
          {:addr, {a, b, c, d}} <- opts,
          a != 127 do
        {ifname, "#{a}.#{b}.#{c}.#{d}"}
      end

    case Enum.find(ips, fn {ifname, _} -> to_string(ifname) == "eth0" end) do
      {_, ip} -> ip
      # fallback
      nil -> ips |> List.first() |> elem(1)
    end
  end
end
