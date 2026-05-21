extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var feesh: Fish = $".."



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation=feesh.rotation
	#position=feesh.position
	#global_position=feesh.global_position
	#global_rotation=feesh.global_rotation
	if position != Vector3.ZERO:
		position = Vector3.ZERO
	global_position = feesh.global_position
	global_basis = feesh.global_basis
	#if transform.origin != Vector3.ZERO:
	#	transform.origin = Vector3.ZERO
	
	
	
func flap_reloaded():
	pass
	if feesh.flapstate==-1:
		feesh.flapstate=0

func reached_flapice():
	if feesh.flapstate!=-1:
		animation_tree.set("parameters/Flap/TimeScale/scale", 0.0)
		#animation_player.pause()
		
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "flap":
	#	feesh.flapstate=0
	#	animation_player.play("fall")
	#if anim_name == "splat":
	#	animation_player.play("idle")
	pass # Replace with function body.
