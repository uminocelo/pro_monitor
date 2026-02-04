defmodule LiveMonitor.Stats do
  @moduledoc """
  Fetches real system statistics using Erlang's :os_mon.
  """

  def get_current_stats do
    %{
      cpu: get_cpu_usage(),
      memory: get_memory_usage(),
      disk: get_disk_usage()
    }
  end

  # --- CPU Usage ---
  defp get_cpu_usage do
    # :cpu_sup.util() returns the CPU utilization as a percentage (0..100)
    # Note: On the very first call, it might return 0 while it calibrates.
    case :cpu_sup.util() do
      {:error, _} -> 0
      val -> round(val)
    end
  end

  # --- Memory Usage ---
  defp get_memory_usage do
    # Returns a list of memory data in bytes
    data = :memsup.get_system_memory_data()

    total = data[:system_total_memory]
    free = data[:free_memory]

    # Simple calculation: Used = Total - Free
    used = total - free
    percent = (used / total) * 100

    round(percent)
  end

  # --- Disk Usage ---
  defp get_disk_usage do
    # Returns a list of disks: [{'/', 1024, 50}, ...]
    disks = :disksup.get_disk_data()

    # We try to find the root partition "/"
    # Note: Erlang strings are charlists (single quotes), so we look for ~c"/"
    root_disk = Enum.find(disks, fn {path, _size, _percent} ->
      path == ~c"/"
    end)

    case root_disk do
      {_, _, percent} -> percent
      # Fallback if we can't find root (e.g. on Windows)
      nil -> 0
    end
  end
end
