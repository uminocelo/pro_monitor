defmodule LiveMonitorWeb.MonitorLive do
  use LiveMonitorWeb, :live_view

  # 1. MOUNT: Initialize state and start loop if connected
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_tick()

    {:ok, assign(socket, cpu: 0, memory: 0, is_running: true)}
  end

  # 2. RENDER: The basic HTML to see our data
  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 text-gray-900 p-10">
      <div class="max-w-md mx-auto bg-white rounded-xl shadow-lg overflow-hidden md:max-w-2xl p-8">
        <h1 class="uppercase tracking-wide text-sm text-indigo-500 font-semibold mb-6">
          Server Status: <span class="text-green-600">Online</span>
        </h1>

        <div class="space-y-6">
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-gray-700 font-medium">CPU Usage</span>
              <span class="text-gray-500 text-sm"><%= @cpu %>%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-4">
              <div
                class="bg-blue-600 h-4 rounded-full transition-all duration-500 ease-out"
                style={"width: #{@cpu}%"}
              >
              </div>
            </div>
          </div>

          <div>
            <div class="flex justify-between mb-2">
              <span class="text-gray-700 font-medium">Memory Usage</span>
              <span class="text-gray-500 text-sm"><%= @memory %>%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-4">
              <div
                class="bg-purple-600 h-4 rounded-full transition-all duration-500 ease-out"
                style={"width: #{@memory}%"}
              >
              </div>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4 mt-8 pt-6 border-t border-gray-100">
           <div class="text-center p-4 bg-gray-50 rounded-lg">
             <div class="text-2xl font-bold text-gray-800"><%= @cpu %></div>
             <div class="text-xs text-gray-500 uppercase">Cores Active</div>
           </div>
           <div class="text-center p-4 bg-gray-50 rounded-lg">
             <div class="text-2xl font-bold text-gray-800">1024</div>
             <div class="text-xs text-gray-500 uppercase">Total Threads</div>
           </div>
        </div>

        <div class="mt-8 text-center">
          <button
            phx-click="toggle_updates"
            class={"px-6 py-3 rounded-lg font-bold text-white shadow-md transition-colors duration-200 " <>
              if @is_running, do: "bg-red-500 hover:bg-red-600", else: "bg-green-500 hover:bg-green-600"}
          >
            <%= if @is_running, do: "Pause Updates", else: "Resume Updates" %>
          </button>
        </div>

      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_updates", _params, socket) do
    # 1. Flip the boolean state (true -> false, or false -> true)
    new_state = !socket.assigns.is_running

    # 2. THE CRITICAL STEP:
    # If we are turning it back ON, we must manually restart the timer loop.
    if new_state do
      schedule_tick()
    end

    # 3. Update the socket
    {:noreply, assign(socket, is_running: new_state)}
  end

  # 3. HANDLE INFO: The loop logic
  @impl true
  def handle_info(:tick, socket) do
    if socket.assigns.is_running, do: schedule_tick()

    {:noreply, assign(socket,
      cpu: Enum.random(0..100),
      memory: Enum.random(20..95)
    )}
  end

  # 4. HELPER: The timer
  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)
  end
end
