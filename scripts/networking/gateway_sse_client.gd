class_name GatewaySSEClient
extends Node

## Server-Sent Events (SSE) Streaming Client for Godot 4
## Manages real-time HTTP event stream consumption from the Hermes Gateway.

signal sse_connected
signal sse_disconnected
signal event_received(event_type: String, event_data: Dictionary)
signal sse_error(message: String)

@export var host: String = "127.0.0.1"
@export var port: int = 8642
@export var use_tls: bool = false

var _client: HTTPClient
var _is_connected: bool = false
var _run_id: String = ""
var _api_key: String = ""
var _raw_buffer: String = ""

func _ready() -> void:
	_client = HTTPClient.new()

func connect_to_run_stream(run_id: String, p_api_key: String = "") -> void:
	_run_id = run_id
	_api_key = p_api_key if not p_api_key.is_empty() else OS.get_environment("API_SERVER_KEY")

	var path: String = "/v1/runs/" + _run_id + "/events"
	var err: Error = _client.connect_to_host(host, port)

	if err != OK:
		sse_error.emit("Failed to initiate connection to host: " + str(err))
		return

	_is_connected = false
	_raw_buffer = ""
	set_process(true)

func disconnect_stream() -> void:
	if _client:
		_client.close()
	_is_connected = false
	set_process(false)
	sse_disconnected.emit()

func _process(_delta: float) -> void:
	if not _client:
		return

	_client.poll()
	var status: HTTPClient.Status = _client.get_status()

	match status:
		HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING:
			pass

		HTTPClient.STATUS_CONNECTED:
			if not _is_connected:
				_is_connected = true
				sse_connected.emit()
				_send_sse_request()

		HTTPClient.STATUS_REQUESTING:
			pass

		HTTPClient.STATUS_BODY:
			_read_stream_chunks()

		HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_CONNECTION_ERROR:
			if _is_connected:
				_is_connected = false
				sse_disconnected.emit()
			set_process(false)

func _send_sse_request() -> void:
	var path: String = "/v1/runs/" + _run_id + "/events"
	var headers: PackedStringArray = [
		"Accept: text/event-stream",
		"Cache-Control: no-cache"
	]
	if not _api_key.is_empty():
		headers.append("Authorization: Bearer " + _api_key)

	var err: Error = _client.request(HTTPClient.METHOD_GET, path, headers)
	if err != OK:
		sse_error.emit("Failed to send SSE request: " + str(err))

func _read_stream_chunks() -> void:
	if not _client.has_response():
		return

	while _client.get_status() == HTTPClient.STATUS_BODY:
		_client.poll()
		var chunk: PackedByteArray = _client.read_response_body_chunk()
		if chunk.size() == 0:
			break

		_raw_buffer += chunk.get_string_from_utf8()
		_parse_buffer()

func _parse_buffer() -> void:
	var blocks: PackedStringArray = _raw_buffer.split("\n\n")
	# Leave the last incomplete block in the buffer
	_raw_buffer = blocks[blocks.size() - 1]

	for i in range(blocks.size() - 1):
		var block: String = blocks[i].strip_edges()
		if block.is_empty():
			continue

		var event_type: String = "message"
		var event_data_str: String = ""

		var lines: PackedStringArray = block.split("\n")
		for line in lines:
			var trimmed_line: String = line.strip_edges()
			if trimmed_line.begins_with("event:"):
				event_type = trimmed_line.substring(6).strip_edges()
			elif trimmed_line.begins_with("data:"):
				event_data_str = trimmed_line.substring(5).strip_edges()

		if not event_data_str.is_empty():
			var json: JSON = JSON.new()
			if json.parse(event_data_str) == OK and typeof(json.get_data()) == TYPE_DICTIONARY:
				event_received.emit(event_type, json.get_data())
			else:
				event_received.emit(event_type, {"raw": event_data_str})
