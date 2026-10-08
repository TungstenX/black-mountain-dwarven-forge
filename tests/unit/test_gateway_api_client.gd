extends RefCounted

## Unit Tests for GatewayApiClient

func test_header_generation() -> bool:
	var client = GatewayApiClient.new()
	client.api_key = "test_key_123456"
	var headers: PackedStringArray = client._get_headers()

	var found_auth: bool = false
	var found_content_type: bool = false

	for header in headers:
		if header == "Authorization: Bearer test_key_123456":
			found_auth = true
		elif header == "Content-Type: application/json":
			found_content_type = true

	client.free()
	return found_auth and found_content_type
