tool
extends EditorPlugin

func get_name(): 
	return "InputManager"

func _enter_tree():
	add_autoload_singleton("InputManager", "res://addons/input_manager/input_manager.gd")
	
func _exit_tree():
	remove_autoload_singleton("InputManager")