extends ShapeCast3D

@onready var fish: Fish = $".."
@onready var level_manager: LevelManager = get_tree().current_scene.get_node("LevelManager")

#@onready var mesh_instance_3d: MeshInstance3D = $"../Feesh/MeshInstance3D"

func _ready():
	pass
	#scale.x = scale.x * fish.fish_size
	#scale.y = scale.y * fish.fish_size
	#scale.z = scale.z * fish.fish_size
func _physics_process(_delta):
	if position != Vector3.ZERO:
		position = Vector3.ZERO
	global_position = fish.global_position
	global_basis = fish.global_basis
	#global_rotation.y = fish.global_rotation.y+(deg_to_rad(90))
	
	if is_colliding():
		var hit_object = get_collider(0)
		if hit_object.get_collision_layer_value(3):
			fish.am_finishtouching = true
			level_manager.died=true
			fish.re_sphere()
			print("amfishyyyyyytouching")
		elif hit_object.get_collision_layer_value(4):
			level_manager.died=true
			fish.re_sphere()
			print("fishdeath")
	else:
		fish.am_finishtouching = false
	
