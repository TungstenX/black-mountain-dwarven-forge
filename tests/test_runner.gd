extends SceneTree

## Headless Unit Test Runner for Godot 4
## Runs unit tests in `res://tests/unit/` and reports results to stdout.

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _init() -> void:
	print("\n==================================================")
	print("  DWARF FORGE GDScript Unit Test Runner (Godot 4)")
	print("==================================================\n")

	_run_all_tests()

	print("\n--------------------------------------------------")
	print("Test Results: %d Passed, %d Failed (Total: %d)" % [passed_tests, failed_tests, total_tests])
	print("--------------------------------------------------\n")

	if failed_tests > 0:
		quit(1)
	else:
		quit(0)

func _run_all_tests() -> void:
	var test_files: Array[String] = [
		"res://tests/unit/test_agent_profile.gd",
		"res://tests/unit/test_agent_state_machine.gd",
		"res://tests/unit/test_gateway_api_client.gd"
	]

	for file_path in test_files:
		_run_test_file(file_path)

func _run_test_file(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		push_warning("Test file not found: " + file_path)
		return

	var script: GDScript = load(file_path)
	if not script:
		push_error("Failed to load script: " + file_path)
		failed_tests += 1
		return

	var test_instance: Object = script.new()
	print("Running Suite: ", file_path.get_file())

	var method_list: Array = test_instance.get_method_list()
	for method_info in method_list:
		var method_name: String = method_info["name"]
		if method_name.begins_with("test_"):
			total_tests += 1
			print("  -> %s()..." % method_name)
			var success: bool = test_instance.call(method_name)
			if success:
				passed_tests += 1
				print("     [PASS]")
			else:
				failed_tests += 1
				print("     [FAIL]")
