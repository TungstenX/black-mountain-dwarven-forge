class_name ErrorState
extends AgentState

## Agent Error State
## Triggered when an error occurs during execution.

var error_message: String = ""

func _init() -> void:
	state_name = &"error"

func enter(data: Dictionary = {}) -> void:
	if data.has("message"):
		error_message = data["message"]
	# Trigger error visual indication (e.g., red flash)

func handle_gateway_event(event_type: String, data: Dictionary) -> void:
	match event_type:
		"run_start", "reset":
			state_finished.emit(&"idle", data)
