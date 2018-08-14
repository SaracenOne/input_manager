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
	enum {TYPE_ACTION, TYPE_MOUSE_MOTION}
	
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
	
	if p_input_axis.type == InputAxis.TYPE_ACTION:
		if InputMap.has_action(p_input_axis.positive_action):
			out_axis += Input.get_action_strength(p_input_axis.positive_action)
		if InputMap.has_action(p_input_axis.negative_action):
			out_axis -= Input.get_action_strength(p_input_axis.negative_action)
			
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
						axes_values[current_axis.name] = clamp(value - p_event.relative.y * 0.01, -1.0, 1.0)
	
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
		
func add_new_axes(p_name, p_positive_action = "", p_negative_action = "", p_gravity = 0.0, p_dead_zone = 0.0, p_sensitivity = 1.0, p_inverted = false, p_type = InputAxis.TYPE_ACTION, p_axis = 0):
	axes.append(InputAxis.new(p_name, p_positive_action, p_negative_action, p_gravity, p_dead_zone, p_sensitivity, p_inverted, p_type, p_axis))
	axes_values[p_name] = 0.0

func set_active(p_active):
	if !Engine.is_editor_hint():
		set_process(p_active)
		set_process_input(p_active)
	
func _ready():
	if !Engine.is_editor_hint():
		set_active(true)
	
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