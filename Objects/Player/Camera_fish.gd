extends Node3D

@export_category("configurables")
@export var cam_v_max: float = 110.0
@export var cam_v_min: float = -75.0
@export var h_sensitivity: float = 0.1
@export var v_sensitivity: float = 0.1
@export var h_acceleration: float = 15.0
@export var v_acceleration: float = 15.0
@export var finish_rotation_speed: float = 25 
@export var smooth_camera_tolerance_small : float = 0.3
@export var smooth_camera_tolerance_big : float = 0.1

var smooth_camera_tolerance: float = 0.3

var camrot_h: float = 0.0
var camrot_v: float = 0.0
var level_finished = false

var camlock : int = 0 #0 = nolock
var cambigsmooth : int = 0

@onready var meshie: MeshInstance3D = $"../Feesh/flatfish/Armature/Skeleton3D/Cube"
#@onready var feesh: Fish = $"../Feesh"
@onready var fish: Fish = $"../Feesh"
@onready var h_rot: Node3D = $hRot
@onready var v_rot: Node3D = $hRot/vRot
@onready var level_manager: LevelManager = get_tree().root.find_child("LevelManager", true, false) # $"../../../LevelManager"


# Called when the node enters the scene tree for the first time.
func _ready(): #-> void:
	# hide mouse at start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

func _physics_process(delta): #fish.get_node("MeshInstance3D")
	if cambigsmooth>0:
		cambigsmooth-=1
		smooth_camera_tolerance = smooth_camera_tolerance_big
	else:
		smooth_camera_tolerance = smooth_camera_tolerance_small
	
	
	if camlock==0:
		global_position = lerp(global_position,fish.global_position,smooth_camera_tolerance)
	if camlock>0:
		camlock-=1
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		
	
	if level_finished or level_manager.pause_toggle == 1:
		#h_rot.rotation_degrees.y = lerp(h_rot.rotation_degrees.y, h_rot.rotation_degrees.y + 1, finish_rotation_speed * delta)
		#v_rot.rotation_degrees.x = lerp(v_rot.rotation_degrees.x, 0.0, 2 * delta)
		pass
	else:
		h_rot.rotation_degrees.y = lerp(h_rot.rotation_degrees.y, camrot_h, delta * h_acceleration)
		v_rot.rotation_degrees.x = lerp(v_rot.rotation_degrees.x, camrot_v, delta * v_acceleration)
		
	rotation_degrees.z = 0	
		
func _input(event):
	if (level_manager.pause_toggle == 0) and event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += -event.relative.y * v_sensitivity
