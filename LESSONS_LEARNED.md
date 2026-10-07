# Lessons Learned & GDScript Pitfalls (Godot 4)

This file tracks technical pitfalls, API breaking changes from Godot 3 to Godot 4, and best practices learned during the development of Black Mountain Dwarven Forge.

---

## 1. String Slicing in GDScript (`substr` vs `substring`)

* **Pitfall:** Using `string.substring(from)` will fail at runtime with `Error: The method 'substring' does not exist for String`.
* **Correct Syntax:** Use **`string.substr(from, length)`**.
  ```gdscript
  # BAD:
  var event_type = line.substring(6)

  # GOOD (Godot 4):
  var event_type = line.substr(6)
  ```

---

## 2. Godot 3 → Godot 4 Syntax Migration Quick Reference

| Feature | Godot 3 Syntax | Godot 4 Syntax |
|---|---|---|
| Export Variable | `export var speed = 10` | `@export var speed: float = 10.0` |
| Onready Variable | `onready var label = $Label` | `@onready var label: Label = $Label` |
| String Slicing | `str.substr(...)` | `str.substr(from, length)` |
| Connecting Signals | `signal.connect("name", target, "method")` | `signal_name.connect(_on_handler)` |
| Emitting Signals | `emit_signal("name", args)` | `signal_name.emit(args)` |
| JSON Parsing | `var p = JSON.parse(text); p.result` | `var json = JSON.new(); json.parse(text); json.get_data()` |
