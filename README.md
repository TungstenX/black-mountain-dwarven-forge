# Black Mountain Dwarven Forge

A cyberpunk forge dashboard and visual interface built in **Godot 4** for visualizing and interacting with **Hermes AI Agents** (Ragoth, Scout, Durnir) in real time.

---

## 🛠️ Requirements & Compatibility
* **Engine Version:** Godot 4.3+ / 4.7.2+
* **Language:** GDScript (Typed Godot 4 Syntax)
* **License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

---

## 🏗️ Folder Structure

```
black-mountain-dwarven-forge/
├── project.godot               # Godot 4 Project Configuration
├── icon.svg                    # Application Icon
├── LICENSE                     # CC BY-NC-SA 4.0 License
├── README.md                   # Documentation & Architecture Overview
├── scenes/
│   ├── main.tscn               # Main Scene Setup
│   └── components/             # Reusable UI & Agent Component Scenes
└── scripts/
    ├── main.gd                 # Main Controller & Orchestrator
    ├── models/
    │   └── agent_profile.gd    # Agent Data Model & Status Tracking
    ├── networking/
    │   ├── gateway_api_client.gd # Async HTTP REST Client (Polling & Queries)
    │   └── gateway_sse_client.gd # Real-time SSE Stream Reader (HTTPClient)
    └── state/
        ├── agent_state.gd      # Base State Class
        ├── agent_state_machine.gd # State Machine Manager
        └── states/             # Concrete FSM States
            ├── idle_state.gd
            ├── thinking_state.gd
            ├── running_tool_state.gd
            └── error_state.gd
```

---

## 🌐 Networking Architecture

1. **`GatewayApiClient` (`scripts/networking/gateway_api_client.gd`):**
   * Uses Godot 4 `HTTPRequest` to query the Hermes Gateway API server (`http://localhost:8642`).
   * Polls `/health/detailed` and `/api/sessions`.
   * Supports multi-profile path prefixes (`/p/{profile}/...`).
   * Authenticates using `Authorization: Bearer <API_SERVER_KEY>`.

2. **`GatewaySSEClient` (`scripts/networking/gateway_sse_client.gd`):**
   * Uses Godot 4 `HTTPClient` to maintain a non-blocking chunked event stream to `/v1/runs/{run_id}/events`.
   * Parses Server-Sent Event (SSE) blocks (`event: ...\ndata: ...\n\n`) and emits typed Godot 4 signals (`event_received`).

---

## ⚙️ Finite State Machine (FSM)

Each agent profile node is driven by `AgentStateMachine`:
* **`IdleState`:** Resting state awaiting commands.
* **`ThinkingState`:** Generating response / reasoning.
* **`RunningToolState`:** Executing a tool (e.g. terminal, browser, file I/O). Triggers forge animations & sparks.
* **`ErrorState`:** Visual error feedback.

---

## 🚀 Getting Started

1. **Open in Godot 4:**
   Import `project.godot` into Godot Engine (version 4.3 or 4.7.2).

2. **Configure Gateway Key (Optional):**
   Set the `API_SERVER_KEY` environment variable on your machine or configure `api_key` in the `GatewayApiClient` inspector node.

3. **Run the Main Scene (`scenes/main.tscn`):**
   Press `F5` in Godot to run the dashboard. Output logs will display connected agents, health metrics, and streaming SSE events!
