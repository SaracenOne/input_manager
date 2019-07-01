extends Node
tool

const DS4_Name : String = "Sony DualShock 4"
const DS4_GUID : String = "4c05cc09000000000000504944564944"

enum {TYPE_XINPUT, TYPE_DS4, TYPE_UNKNOWN}
var connected_joypads : Array = []
var window_has_focus : bool = true

static func get_joy_type_from_guid(p_guid : String):
	if p_guid == DS4_GUID:
		return TYPE_DS4
	else:
		return TYPE_XINPUT
	
class JoyPadInfo:
	enum {TYPE_XINPUT, TYPE_DUALSHOCK, TYPE_UNKNOWN}
	var type : int = TYPE_UNKNOWN
	
	func _init(p_type : int):
		type = p_type

var axes_values : Dictionary = {}
var axes : Array = []

class InputAxis:
	enum {TYPE_ACTION, TYPE_MOUSE_MOTION}
	
	var name : String = ""
	var positive_action : String = ""
	var negative_action : String = ""
	var gravity : float = 0.0
	var dead_zone : float = 0.0
	var sensitivity : float = 1.0
	var inverted : bool = false
	var type : int = TYPE_ACTION
	var axis : int = 0
	
	func _init(
		p_name : String,
		p_positive_action : String = "",
		p_negative_action : String = "",
		p_gravity : float = 0.0,
		p_dead_zone: float = 0.0,
		p_sensitivity : float = 1.0,
		p_inverted : bool = false,
		p_type : int = TYPE_ACTION,
		p_axis : int = 0) -> void:
			
		name = p_name
		positive_action = p_positive_action
		negative_action = p_negative_action
		gravity = p_gravity
		dead_zone = p_dead_zone
		sensitivity = p_sensitivity
		inverted = p_inverted
		type = p_type
		axis = p_axis

func evaluate_single_axis(p_input_axis : InputAxis) -> float:
	var out_axis : float = 0.0
	
	if p_input_axis.type == InputAxis.TYPE_ACTION:
		if InputMap.has_action(p_input_axis.positive_action):
			out_axis += Input.get_action_strength(p_input_axis.positive_action)
		if InputMap.has_action(p_input_axis.negative_action):
			out_axis -= Input.get_action_strength(p_input_axis.negative_action)
			
	out_axis = clamp(out_axis, -1.0, 1.0)
	
	return out_axis

func update_all_axis() -> void:
	if window_has_focus:
		for current_axis in axes:
			var value : float = evaluate_single_axis(current_axis)
			axes_values[current_axis.name] = value

func _input(p_event) -> void:
	if !Engine.is_editor_hint():
		if(p_event is InputEventMouseMotion):
			for current_axis in axes:
				if current_axis.type == InputAxis.TYPE_MOUSE_MOTION and (current_axis.axis == 0 or current_axis.axis == 1):
					var value : float = axes_values[current_axis.name]
					if current_axis.axis == 0:
						axes_values[current_axis.name] = clamp(value + p_event.relative.x * 0.01, -1.0, 1.0)
					if current_axis.axis == 1:
						axes_values[current_axis.name] = clamp(value - p_event.relative.y * 0.01, -1.0, 1.0)
	
func _process(p_delta : float) -> void:
	if p_delta > 0.0:
		if !Engine.is_editor_hint():
			update_all_axis()
	
func _joy_connection_changed(p_index : int, p_connected : bool) -> void:
	if !Engine.is_editor_hint():
		var connection_status : String = ""
		if p_connected:
			connected_joypads.push_back(p_index)
			
			connected_joypads[p_index] = JoyPadInfo.new(get_joy_type_from_guid(Input.get_joy_guid(p_index)))
			connection_status = "connected"
		else:
			if connected_joypads.erase(p_index) == false:
				printerr("Could not erase joypad index: " + str(p_index))
			connection_status = "disconnected"
			
		print("Connection changed: " + str(p_index) + " - " + connection_status)
	
func enter_tree() -> void:
	if !Engine.is_editor_hint():
		var connect_result : int = Input.connect("joy_connection_changed", self, "_joy_connection_changed")
		if connect_result != OK:
			printerr("joy_connection_changed: could not connect!")
	
func exit_tree() -> void:
	if !Engine.is_editor_hint():
		if Input.is_connected("joy_connection_changed", self, "_joy_connection_changed"):
			Input.disconnect("joy_connection_changed", self, "_joy_connection_changed")
		
func add_new_axes(
	p_name : String,
	p_positive_action : String = "",
	p_negative_action : String = "",
	p_gravity : float = 0.0,
	p_dead_zone : float = 0.0,
	p_sensitivity : float = 1.0,
	p_inverted : bool = false,
	p_type : int = InputAxis.TYPE_ACTION,
	p_axis : int = 0):
	
	axes.append(InputAxis.new(p_name, p_positive_action, p_negative_action, p_gravity, p_dead_zone, p_sensitivity, p_inverted, p_type, p_axis))
	axes_values[p_name] = 0.0

func set_active(p_active : bool) -> void:
	if !Engine.is_editor_hint():
		set_process(p_active)
		set_process_input(p_active)
		
func _notification(p_notification : int) -> void:
	match p_notification:
		NOTIFICATION_WM_FOCUS_IN:
			window_has_focus = true
		NOTIFICATION_WM_FOCUS_OUT:
			window_has_focus = false
	
func _ready() -> void:
	if !Engine.is_editor_hint():
		set_active(true)
	
		print("connected joypads:")
		if(Input.get_connected_joypads().size() == 0):
			print("No joypads connected.")
		else:
			for joypad in Input.get_connected_joypads():
				print(str(Input.get_joy_name(joypad)))
				print(str(Input.get_joy_guid(joypad)))
	else:
		set_process(false)
		set_physics_process(false)
	
	if(!ProjectSettings.has_setting("gameplay/invert_look_x")):
		ProjectSettings.set_setting("gameplay/invert_look_x", false)
		
	if(!ProjectSettings.has_setting("gameplay/invert_look_y")):
		ProjectSettings.set_setting("gameplay/invert_look_y", false)
