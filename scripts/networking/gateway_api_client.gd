class_name GatewayApiClient
extends Node

## Hermes Gateway REST API Client for Godot 4
## Manages async HTTP requests to the Hermes Gateway REST endpoints.

signal health_updated(data: Dictionary)
signal sessions_updated(sessions: Array)
signal request_failed(endpoint: String, error_message: String)

@export var base_url: String = "http://localhost:8642"
@export var api_key: String = ""
@export var auto_poll: bool = true
@export var poll_interval_seconds: float = 5.0

var _http_request: HTTPRequest
var _poll_timer: Timer

func _ready() -> void:
	# Resolve API Key from Environment if not set via Inspector
	if api_key.is_empty():
		api_key = OS.get_environment("API_SERVER_KEY")

	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

	if auto_poll:
		_setup_polling()

func _setup_polling() -> void:
	_poll_timer = Timer.new()
	_poll_timer.wait_time = poll_interval_seconds
	_poll_timer.autostart = true
	_poll_timer.timeout.connect(poll_health)
	add_child(_poll_timer)
	poll_health()

## Build Authorization and Content-Type Headers
func _get_headers() -> PackedStringArray:
	var headers: PackedStringArray = [
		"Content-Type: application/json"
	]
	if not api_key.is_empty():
		headers.append("Authorization: Bearer " + api_key)
	return headers

## Fetch Detailed Gateway Health and Topology
func poll_health(profile_prefix: String = "") -> void:
	var path: String = "/health/detailed"
	if not profile_prefix.is_empty():
		path = "/p/" + profile_prefix + path

	var url: String = base_url + path
	var err: Error = _http_request.request(url, _get_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		request_failed.emit(path, "Failed to initiate HTTP request, code: " + str(err))

## Fetch Active Hermes Sessions
func fetch_sessions(profile_prefix: String = "") -> void:
	var path: String = "/api/sessions"
	if not profile_prefix.is_empty():
		path = "/p/" + profile_prefix + path

	var url: String = base_url + path
	var err: Error = _http_request.request(url, _get_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		request_failed.emit(path, "Failed to initiate sessions request, code: " + str(err))

## Handle HTTP Response Completion
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("unknown", "HTTP Result error: " + str(result))
		return

	if response_code != 200:
		request_failed.emit("unknown", "HTTP Status Error: " + str(response_code))
		return

	var body_string: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(body_string)

	if parse_err != OK:
		request_failed.emit("unknown", "JSON Parse Error: " + json.get_error_message())
		return

	var data: Variant = json.get_data()
	if typeof(data) == TYPE_DICTIONARY:
		var dict_data: Dictionary = data
		if dict_data.has("status") or dict_data.has("platforms") or dict_data.has("profiles"):
			health_updated.emit(dict_data)
		elif dict_data.has("sessions"):
			sessions_updated.emit(dict_data["sessions"])
	elif typeof(data) == TYPE_ARRAY:
		sessions_updated.emit(data)
