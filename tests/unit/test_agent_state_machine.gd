extends RefCounted

## Unit Tests for AgentStateMachine and States

func test_state_creation() -> bool:
	var idle_state = IdleState.new()
	if idle_state.state_name != &"idle":
		return false

	var thinking_state = ThinkingState.new()
	if thinking_state.state_name != &"thinking":
		return false

	var running_tool_state = RunningToolState.new()
	if running_tool_state.state_name != &"running_tool":
		return false

	var error_state = ErrorState.new()
	if error_state.state_name != &"error":
		return false

	return true

func test_running_tool_state_data() -> bool:
	var state = RunningToolState.new()
	state.enter({"tool_name": "terminal"})
	if state.current_tool_name != "terminal":
		return false
	return true
