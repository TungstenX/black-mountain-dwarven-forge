class_name IdleState
extends AgentState

## Agent Idle State
## Triggered when the agent profile is resting and awaiting commands.

func _init() -> void:
	state_name = &"idle"

func enter(_data: Dictionary = {}) -> void:
	# Trigger idle animation / particle effects
	pass

func handle_gateway_event(event_type: String, data: Dictionary) -> void:
	match event_type:
		"run_start", "thinking":
			state_finished.emit(&"thinking", data)
		"tool_start":
			state_finished.emit(&"running_tool", data)
		"error":
			state_finished.emit(&"error", data)
