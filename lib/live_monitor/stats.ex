defmodule LiveMonitor.Stats do
  @moduledoc """
  Responsible for fetching system statistics.
  Currently simulates data, but could be swapped for real OS calls later.
  """

  def get_current_stats do
    %{
      cpu: Enum.random(0..100),
      memory: Enum.random(20..95),
      disk: 45 # Static for now
    }
  end
end
