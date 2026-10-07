extends Node

## Main Controller for Black Mountain Dwarven Forge (Godot 4)

@onready var api_client: GatewayApiClient = $GatewayApiClient
@onready var sse_client: GatewaySSEClient = $GatewaySSEClient

var agent_profiles: Dictionary = {} # profile_id -> AgentProfile

func _ready() -> void:
	print("Initializing Black Mountain Dwarven Forge Dashboard...")

	api_client.health_updated.connect(_on_health_updated)
	api_client.sessions_updated.connect(_on_sessions_updated)
	api_client.request_failed.connect(_on_request_failed)

	sse_client.event_received.connect(_on_sse_event_received)
	sse_client.sse_connected.connect(_on_sse_connected)
	sse_client.sse_disconnected.connect(_on_sse_disconnected)

	# Register default profiles
	_register_profile("default", "Ragoth", "Master Smith & Lead Agent")
	_register_profile("scout", "Scout", "Signal & Research Scout")
	_register_profile("durnir", "Durnir", "Security & Guard")

func _register_profile(id: String, name: String, role: String) -> void:
	var profile = AgentProfile.new(id, name, role)
	agent_profiles[id] = profile
	print("Registered agent profile: ", name, " (", role, ")")

func _on_health_updated(data: Dictionary) -> void:
	print("[Gateway Health Updated]: ", data.get("status", "ok"))

func _on_sessions_updated(sessions: Array) -> void:
	print("[Gateway Active Sessions]: ", sessions.size(), " active sessions found.")

func _on_request_failed(endpoint: String, error_message: String) -> void:
	push_warning("[Gateway Request Error] ", endpoint, ": ", error_message)

func _on_sse_connected() -> void:
	print("[SSE Stream Connected]")

func _on_sse_disconnected() -> void:
	print("[SSE Stream Disconnected]")

func _on_sse_event_received(event_type: String, event_data: Dictionary) -> void:
	print("[SSE Event] ", event_type, ": ", event_data)
