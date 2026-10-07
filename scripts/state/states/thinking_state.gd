class_name ThinkingState
extends AgentState

## Agent Thinking State
## Triggered when the agent profile is generating response or reasoning.

func _init() -> void:
	state_name = &"thinking"

func enter(_data: Dictionary = {}) -> void:
	# Trigger thinking animation / glow
	pass

func handle_gateway_event(event_type: String, data: Dictionary) -> void:
	match event_type:
		"tool_start":
			state_finished.emit(&"running_tool", data)
		"run_complete", "turn_complete":
			state_finished.emit(&"idle", data)
		"error":
			state_finished.emit(&"error", data)
