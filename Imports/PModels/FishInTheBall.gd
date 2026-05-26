extends Node3D

@onready var marble: Marble = $"../Marble"
@onready var mesh_instance_3d: MeshInstance3D = $"../Marble/MeshInstance3D"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var nose_3d: Node3D = $Armature/Skeleton3D/Cube/Nose3D

var flat_forward : Vector3
var raw_basis : Basis

var torpedo_max_buffer : int = 31
var torpedo_speed : float = 1

var supertorpedo_mode : int = -1
var supertorpedo_angle : float = 0
var supertorpedo_accel : float = 0.125
var supertorpedo_speed : float = 0
var supertorpedo_speed_deaccel : float = 0.1
var max_supertorpedo_speed : float = 12.0
var supertorpedo_buffer : int = 0
var supertorpedo_max_buffer : int = 30


var torpedo_target = 0 # 90 degrees RIGHT or LEFT
var torpedo_left = -1
var torpedo_right = -1
# -1 = NOT PRESSED. 1 = PRESSED. 0 = RELEASED, TILTED 
var torpedo_correction : float = 0
var torpedo_correction_turbo : float = 0
#@onready var mesh_instance_3d: MeshInstance3D = $"../Marble/MeshInstance3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animation_player.play("swim")
	playback.travel("Swim")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = mesh_instance_3d.global_position
	
	#region torpedo
	var torpedo_left_input = Input.get_action_raw_strength("up")
	var torpedo_right_input = Input.get_action_raw_strength("down")
	
	if torpedo_right_input and torpedo_left_input:
		if supertorpedo_mode==-1: #this decides the angle of tilt
			supertorpedo_mode=0
			supertorpedo_buffer=supertorpedo_max_buffer
			if torpedo_left>=0:
				supertorpedo_angle+=1
			elif torpedo_right>=0:
				supertorpedo_angle-=1
			elif randi_range(0,1) == 0:
				supertorpedo_angle+=1
			else:
				supertorpedo_angle-=1
			torpedo_left=-1
			torpedo_right=-1
		else:	
			supertorpedo_mode+=1
			if supertorpedo_angle>0:
				supertorpedo_speed+=supertorpedo_accel
			else:
				supertorpedo_speed-=supertorpedo_accel
			supertorpedo_speed=clamp(supertorpedo_speed,-max_supertorpedo_speed,max_supertorpedo_speed)
			supertorpedo_angle+=supertorpedo_speed
			
	else:
		supertorpedo_buffer=clamp(supertorpedo_buffer-1,0,supertorpedo_max_buffer)
		if supertorpedo_mode!=-1:
			supertorpedo_mode=-1
			torpedo_correction=snapped(supertorpedo_angle,90)
			supertorpedo_angle=0
		supertorpedo_speed=clamp(supertorpedo_speed-supertorpedo_speed_deaccel,0.0,max_supertorpedo_speed)
		
		
		
		#print(str(supertorpedo_snapped_angle))
		if (supertorpedo_angle>0 and supertorpedo_angle<0.01) or (supertorpedo_angle<0 and supertorpedo_angle>-0.01):
			supertorpedo_angle=0
		
	
	if torpedo_left_input and !torpedo_right_input: #TORPEDO INPUT PRESSED
		if torpedo_left==-1:
			torpedo_left=torpedo_max_buffer
			if !supertorpedo_buffer>0:
				torpedo_target=snapped(torpedo_correction+90,90)
			#torpedo_target=torpedo_correction+90
		#else:
			#torpedo_left=-1
			
		if torpedo_left>0:
			torpedo_left-=1
			
		# START ADJUSTING ANGLE
		torpedo_correction+=torpedo_speed
			
	else: #TORPEDO INPUT NOT PRESSED
		if torpedo_left>0 and !supertorpedo_buffer>0:
			# SKIP TO 90 DEGREE ANGLE
			torpedo_correction=torpedo_target
			
		torpedo_left=-1
		
	if torpedo_right_input and !torpedo_left_input: #TORPEDO INPUT PRESSED
		if torpedo_right==-1:
			torpedo_right=torpedo_max_buffer
			if !supertorpedo_buffer>0:
				torpedo_target=snapped(torpedo_correction-90,90)
			#torpedo_target=torpedo_correction+90
		#else:
			#torpedo_left=-1
			
		if torpedo_right>0:
			torpedo_right-=1
			
		# START ADJUSTING ANGLE
		torpedo_correction-=torpedo_speed
			
	else: #TORPEDO INPUT NOT PRESSED
		if torpedo_right>0 and !supertorpedo_buffer>0:
			# SKIP TO 90 DEGREE ANGLE
			torpedo_correction=torpedo_target
			
		torpedo_right=-1
	
	torpedo_correction_turbo = torpedo_correction + supertorpedo_angle
	#endregion
	
	var myforward = Vector3.FORWARD
	var myback = Vector3.BACK
	raw_basis = global_transform.basis
	flat_forward = -raw_basis.z
	flat_forward.y = 0
	flat_forward = flat_forward.normalized()
	
	
