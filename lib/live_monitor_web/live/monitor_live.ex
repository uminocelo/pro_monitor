defmodule LiveMonitorWeb.MonitorLive do
  use LiveMonitorWeb, :live_view

  # Alias our new logic module so we can call it easily
  alias LiveMonitor.Stats

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_tick()

    # Initial fetch of data
    initial_stats = Stats.get_current_stats()

    {:ok, assign(socket,
      cpu: initial_stats.cpu,
      memory: initial_stats.memory,
      disk: initial_stats.disk, # Add this
      is_running: true
    )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 text-gray-900 p-10">
      <div class="max-w-md mx-auto bg-white rounded-xl shadow-lg p-8">
        <h1 class="text-xl font-bold mb-6 text-indigo-600">Server Monitor</h1>

        <.progress_bar label="CPU Usage" value={@cpu} color="blue" />
        <.progress_bar label="Memory Usage" value={@memory} color="purple" />
        <.progress_bar label="Disk Usage (Root)" value={@disk} color="yellow" />

        <div class="mt-8 text-center">
          <button phx-click="toggle_updates" class={"px-6 py-2 rounded text-white " <>
              if @is_running, do: "bg-red-500 hover:bg-red-600", else: "bg-green-500 hover:bg-green-600"}>
            <%= if @is_running, do: "Pause", else: "Resume" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:tick, socket) do
    if socket.assigns.is_running, do: schedule_tick()

    # We fetch new stats from our Logic Module
    new_stats = Stats.get_current_stats()

    {:noreply, assign(socket, cpu: new_stats.cpu, memory: new_stats.memory, disk: new_stats.disk)}
  end

  @impl true
  def handle_event("toggle_updates", _params, socket) do
    new_state = !socket.assigns.is_running
    if new_state, do: schedule_tick()
    {:noreply, assign(socket, is_running: new_state)}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :color, :string, default: "blue"

  defp progress_bar(assigns) do
    # FIX: We map the simple name to the full Tailwind class.
    # Because the full strings "bg-blue-600" etc. exist here,
    # Tailwind will see them and generate the CSS.
    color_class = case assigns.color do
      "blue"   -> "bg-blue-600"
      "purple" -> "bg-purple-600"
      "yellow" -> "bg-yellow-500" # Yellow-500 usually looks better than 600
      _        -> "bg-gray-600"   # Fallback
    end

    # We assign this new class to the socket assigns for use in the template
    assigns = assign(assigns, :color_class, color_class)

    ~H"""
    <div class="mb-6">
      <div class="flex justify-between mb-2">
        <span class="text-gray-700 font-medium"><%= @label %></span>
        <span class="text-gray-500 text-sm"><%= @value %>%</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-4">
        <div
          class={@color_class <> " h-4 rounded-full transition-all duration-500 ease-out"}
          style={"width: #{@value}%"}
        >
        </div>
      </div>
    </div>
    """
  end
end
