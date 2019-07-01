tool
extends EditorPlugin

func get_name() -> String: 
	return "InputManager"

func _enter_tree() -> void:
	add_autoload_singleton("InputManager", "res://addons/input_manager/input_manager.gd")
	
func _exit_tree() -> void:
	remove_autoload_singleton("InputManager")
