# Physical Resources Observer Monitor

A real-time server monitoring dashboard built with **Elixir** and **Phoenix LiveView**. This application tracks system resources (CPU, Memory, Disk) and updates the UI dynamically without page refreshes, demonstrating the power of the BEAM's actor model and stateful connections.

## Features

- **Real-Time Updates:** Pushes server metrics to the client every second using WebSocket connections (no polling).
- **Live System Data:** Utilizes Erlang's built-in `:os_mon` application to fetch actual OS metrics (CPU load, RAM usage, Partition usage).
- **Interactive Controls:** Includes a Pause/Resume feature that manages the server-side timer loop via client events.
- **Reactive UI:** Built with functional components and Tailwind CSS for smooth, animated progress bars.

## Technical Stack

- **Framework:** Phoenix LiveView
- **Language:** Elixir
- **Styling:** Tailwind CSS
- **System Monitoring:** Erlang `:os_mon` (`:cpu_sup`, `:memsup`, `:disksup`)

## How it Works

1. **The Loop:** The LiveView process initiates a recursive timer using `Process.send_after/3` upon mounting.
2. **The State:** The dashboard state is held in the LiveView socket assigns.
3. **The Update:** When the timer ticks, the `handle_info/2` callback fetches fresh data from the `LiveMonitor.Stats` context and pushes only the _diffs_ to the browser.
4. **The Interaction:** Clicking "Pause" cancels the recursive scheduling, effectively putting the monitoring process to sleep until the user wakes it up.

## Getting Started

To run this project on your machine:

1. **Clone the repository:**

```bash
git clone https://github.com/uminocelo/pro_monitor.git
cd pro_monitor

```

2. **Install dependencies:**

```bash
mix deps.get

```

3. **Start the server:**

```bash
mix phx.server

```

4. **Visit the dashboard:**
   Open `http://localhost:4000/monitor` in your browser.

---

### Key Learning Concepts

This project was built to practice:

- `handle_info/2` and `Process.send_after/3` for server-side loops.
- Separating Business Logic (Stats Context) from Presentation (LiveView).
- Using Phoenix Function Components for reusable UI elements.
- Interfacing Elixir with Erlang OTP libraries.
