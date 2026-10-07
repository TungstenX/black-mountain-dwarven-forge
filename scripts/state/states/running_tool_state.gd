class_name RunningToolState
extends AgentState

## Agent Tool Execution State
## Triggered when the agent profile is executing a tool (e.g. terminal, browser, file).

var current_tool_name: String = ""

func _init() -> void:
	state_name = &"running_tool"

func enter(data: Dictionary = {}) -> void:
	if data.has("tool_name"):
		current_tool_name = data["tool_name"]
	# Trigger tool execution animation (e.g., anvil sparks for Ragoth)

func handle_gateway_event(event_type: String, data: Dictionary) -> void:
	match event_type:
		"tool_complete":
			state_finished.emit(&"thinking", data)
		"run_complete":
			state_finished.emit(&"idle", data)
		"error":
			state_finished.emit(&"error", data)
