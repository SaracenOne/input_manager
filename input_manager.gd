extends Node
tool

const DS4_Name = "Sony DualShock 4"
const DS4_GUID = "4c05cc09000000000000504944564944"

var connected_joypads = []

class JoyPadInfo:
	enum {TYPE_XINPUT, TYPE_DUALSHOCK, TYPE_UNKNOWN}
	var type = TYPE_UNKNOWN

var axes_values = {}
var axes = []

class InputAxis:
	enum {TYPE_ACTION, TYPE_MOUSE_MOTION, TYPE_JOY_AXIS}
	
	var name = ""
	var positive_action = ""
	var negative_action = ""
	var gravity = 0.0
	var dead_zone = 0.0
	var sensitivity = 1.0
	var inverted = false
	var type = TYPE_ACTION
	var axis = 0
	
	func _init(p_name, p_positive_action = "", p_negative_action = "", p_gravity = 0.0, p_dead_zone = 0.0, p_sensitivity = 1.0, p_inverted = false, p_type = TYPE_ACTION, p_axis = 0.0):
		name = p_name
		positive_action = p_positive_action
		negative_action = p_negative_action
		gravity = p_gravity
		dead_zone = p_dead_zone
		sensitivity = p_sensitivity
		inverted = p_inverted
		type = p_type
		axis = p_axis

func evaluate_single_axis(p_input_axis):
	var out_axis = 0.0
	
	if p_input_axis.type == InputAxis.TYPE_JOY_AXIS:
		out_axis = Input.get_joy_axis(0, p_input_axis.axis)
		
		# Flip the axis
		if p_input_axis.inverted == true:
			out_axis = -out_axis
			
		if(out_axis < p_input_axis.dead_zone and out_axis > -p_input_axis.dead_zone):
			out_axis = 0.0
	elif p_input_axis.type == InputAxis.TYPE_ACTION:
		if InputMap.has_action(p_input_axis.positive_action):
			if(Input.is_action_pressed(p_input_axis.positive_action)):
				out_axis += 1.0
		if InputMap.has_action(p_input_axis.negative_action):
			if(Input.is_action_pressed(p_input_axis.negative_action)):
				out_axis -= 1.0
			
	clamp(out_axis, -1.0, 1.0)
	
	return out_axis

func update_all_axis():
	for current_axis in axes:
		var value = evaluate_single_axis(current_axis)
		axes_values[current_axis.name] = value

func _input(p_event):
	if !Engine.is_editor_hint():
		if(p_event is InputEventMouseMotion):
			for current_axis in axes:
				if current_axis.type == InputAxis.TYPE_MOUSE_MOTION and (current_axis.axis == 0 or current_axis.axis == 1):
					var value = axes_values[current_axis.name]
					if current_axis.axis == 0:
						axes_values[current_axis.name] = clamp(value + p_event.relative.x * 0.01, -1.0, 1.0)
					if current_axis.axis == 1:
						axes_values[current_axis.name] = clamp(value + p_event.relative.y * 0.01, -1.0, 1.0)
	
func _process(delta):
	if !Engine.is_editor_hint():
		update_all_axis()
	
func joy_connection_changed(p_index, p_connected):
	if !Engine.is_editor_hint():
		print("Connection changed: " + str(p_index))
	
func enter_tree():
	if !Engine.is_editor_hint():
		Input.connect("joy_connection_changed", self, "joy_connection_changed")
	
func exit_tree():
	if !Engine.is_editor_hint():
		Input.disconnect("joy_connection_changed", self, "joy_connection_changed")
	
func setup_default_axes():
	axes = [
	InputAxis.new("move_vertical_digital", "move_forwards", "move_backwards", 0.0, 0.0, 1.0, false, InputAxis.TYPE_ACTION, 0),
	InputAxis.new("move_horizontal_digital", "move_right", "move_left", 0.0, 0.0, 1.0, false, InputAxis.TYPE_ACTION, 0),
	InputAxis.new("move_vertical_analog", "", "", 0.0, 0.0, 1.0, true, InputAxis.TYPE_JOY_AXIS, 1),
	InputAxis.new("move_horizontal_analog", "", "", 0.0, 0.0, 1.0, false, InputAxis.TYPE_JOY_AXIS, 0),
	InputAxis.new("mouse_x", "", "", 0.0, 0.0, 1.0, false, InputAxis.TYPE_MOUSE_MOTION, 0),
	InputAxis.new("mouse_y", "", "", 0.0, 0.0, 1.0, false, InputAxis.TYPE_MOUSE_MOTION, 1),
	InputAxis.new("look_vertical_analog", "", "", 0.0, 0.1, 1.0, false, InputAxis.TYPE_JOY_AXIS, 2),
	InputAxis.new("look_horizontal_analog", "", "", 0.0, 0.1, 1.0, false, InputAxis.TYPE_JOY_AXIS, 3)
	]
	
	for input_axis in axes:
		axes_values[input_axis.name] = 0.0
	
func _ready():
	if !Engine.is_editor_hint():
		set_process(true)
		set_process_input(true)
	
		setup_default_axes()
	
		print("connected joypads:")
		if(Input.get_connected_joypads().size() == 0):
			print("No joypads connected.")
		else:
			for joypad in Input.get_connected_joypads():
				print(str(Input.get_joy_name(joypad)))
				print(str(Input.get_joy_guid(joypad)))
	
	if(!ProjectSettings.has_setting("gameplay/invert_look_x")):
		ProjectSettings.set_setting("gameplay/invert_look_x", false)
		
	if(!ProjectSettings.has_setting("gameplay/invert_look_y")):
		ProjectSettings.set_setting("gameplay/invert_look_y", false)