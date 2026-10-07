class_name AgentStateMachine
extends Node

## Agent Finite State Machine (FSM) Manager for Godot 4

signal state_changed(old_state_name: StringName, new_state_name: StringName)

@export var initial_state: AgentState
var current_state: AgentState
var states: Dictionary = {}

func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is AgentState:
			states[child.state_name] = child
			child.state_finished.connect(_on_state_finished)

	if initial_state:
		transition_to(initial_state.state_name)

func transition_to(target_state_name: StringName, data: Dictionary = {}) -> void:
	if not states.has(target_state_name):
		push_error("StateMachine: State '%s' does not exist!" % target_state_name)
		return

	var old_state_name: StringName = &""
	if current_state:
		old_state_name = current_state.state_name
		current_state.exit()

	current_state = states[target_state_name]
	current_state.enter(data)
	state_changed.emit(old_state_name, target_state_name)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func handle_gateway_event(event_type: String, data: Dictionary) -> void:
	if current_state:
		current_state.handle_gateway_event(event_type, data)

func _on_state_finished(next_state_name: StringName, data: Dictionary) -> void:
	transition_to(next_state_name, data)
