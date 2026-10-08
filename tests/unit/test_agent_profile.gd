extends RefCounted

## Unit Tests for AgentProfile Data Model

func test_profile_initialization() -> bool:
	var profile = AgentProfile.new("ragoth", "Ragoth", "Master Smith")
	if profile.id != "ragoth":
		return false
	if profile.name != "Ragoth":
		return false
	if profile.role != "Master Smith":
		return false
	if profile.current_status != "idle":
		return false
	return true

func test_status_update() -> bool:
	var profile = AgentProfile.new("scout", "Scout", "Research Scout")
	var initial_time: float = profile.last_activity_timestamp
	OS.delay_msec(10)
	profile.update_status("running_tool", "web_search")

	if profile.current_status != "running_tool":
		return false
	if profile.active_tool != "web_search":
		return false
	if profile.last_activity_timestamp <= initial_time:
		return false
	return true

func test_dictionary_serialization() -> bool:
	var profile = AgentProfile.new("durnir", "Durnir", "Guard")
	profile.update_status("thinking")
	var dict = profile.to_dict()

	if dict.get("id") != "durnir":
		return false
	if dict.get("name") != "Durnir":
		return false
	if dict.get("status") != "thinking":
		return false
	return true
