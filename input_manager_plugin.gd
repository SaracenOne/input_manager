tool
extends EditorPlugin


func _init() -> void:
	print("Initialising InputManager plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying InputManager plugin")


func get_name() -> String:
	return "InputManager"


func _enter_tree() -> void:
	add_autoload_singleton("InputManager", "res://addons/input_manager/input_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("InputManager")
