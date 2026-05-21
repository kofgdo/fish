extends Node3D

@onready var finisharea: Area3D = $FinishArea
@onready var level_manager: LevelManager = $"../../LevelManager"

@export var finishid : int = -1
@export var validcheckpoint : bool = true

func _ready():
	finisharea.gravity_point_center = Vector3(0,0.275,0)
	

	
func _on_finish_area_body_entered(body: Node3D) -> void:
	
	'''	
	if body.owner.is_in_group("player"): 
		
		#var camera = body.owner.get_node("CameraContainer")
		#camera.smooth_camera_tolerance = .01
		#camera.level_finished = true
		var marble = body.owner.get_node("Marble")
		print("ah")
		if body.level_finish_cooldown_tickstate==0 and body is Marble:#marble.level_finish_cooldown_tickstate==0:
			print("hello, world!")
			marble.can_move = false
			marble.level_finished = true
			
			marble.angular_velocity.x = clamp(marble.angular_velocity.x,-5,5)
			marble.angular_velocity.y = clamp(marble.angular_velocity.y,-5,5)
			marble.angular_velocity.z = clamp(marble.angular_velocity.z,-5,5)
			marble.linear_velocity = Vector3.ZERO
			
			marble.level_finish_cooldown_tickstate = -1
			marble.level_finish_cooldown=body.level_finish_cooldown_max
	'''
	pass # Replace with function body.


func _on_finish_area_body_exited(body: Node3D) -> void:
	'''
	print("DEBUG: Something exited! It is: ", body) # Watch the output console
	print("DEBUG: Body type is ", typeof(body))
	if body == null or not is_instance_valid(body) or body is Fish:
		return
	if body.owner.is_in_group("player"): 
		finisharea.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		finisharea.linear_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
		finisharea.angular_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	'''	
	pass # Replace with function body.
