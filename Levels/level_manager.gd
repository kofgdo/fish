extends Node
class_name LevelManager

var latestcheckpoint: Vector3 = Vector3(0,0,0)
var pause_toggle: int = 0
var stored_mouse_pos: Vector2 = Vector2.ZERO
var died : bool = false
var finishid : int = -1

@onready var menu_screen: Control = $"../CanvasLayer/MenuScreen"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#latestcheckpoint = Vector3(0,0,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	#print(str(finishid))	
	var esc_input = Input.is_action_just_pressed("pause")
	#print(str(latestcheckpoint))
	
	if esc_input == true:
		if pause_toggle == 0:
			menu_screen.visible = true 
			pause_toggle = 1
			stored_mouse_pos = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
		elif pause_toggle == 1:
			menu_screen.visible = false
			pause_toggle = 0
			get_viewport().warp_mouse(stored_mouse_pos)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
