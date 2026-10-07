class_name AgentState
extends Node

## Base State Class for Agent Finite State Machine in Godot 4

signal state_finished(next_state_name: StringName, data: Dictionary)

@export var state_name: StringName = &"base"

## Called when entering this state
func enter(_data: Dictionary = {}) -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Called every frame while in this state
func update(_delta: float) -> void:
	pass

## Called when a gateway event or status update is received
func handle_gateway_event(_event_type: String, _data: Dictionary) -> void:
	pass
