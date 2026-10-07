class_name AgentProfile
extends RefCounted

## Agent Profile Data Model for Godot 4
## Represents an agent profile (e.g. Ragoth, Scout, Durnir) in the Hermes ecosystem.

signal profile_updated

var id: String = ""
var name: String = ""
var role: String = ""
var current_status: String = "idle" # idle, thinking, running_tool, error
var active_tool: String = ""
var last_activity_timestamp: float = 0.0
var metadata: Dictionary = {}

func _init(p_id: String = "", p_name: String = "", p_role: String = "") -> void:
	id = p_id
	name = p_name
	role = p_role
	last_activity_timestamp = Time.get_unix_time_from_system()

func update_status(p_status: String, p_tool: String = "") -> void:
	current_status = p_status
	active_tool = p_tool
	last_activity_timestamp = Time.get_unix_time_from_system()
	profile_updated.emit()

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"role": role,
		"status": current_status,
		"active_tool": active_tool,
		"last_activity": last_activity_timestamp,
		"metadata": metadata
	}
