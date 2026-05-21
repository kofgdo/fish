extends RayCast3D

@onready var fish: RigidBody3D = $".."
@onready var level_manager: LevelManager = get_tree().current_scene.get_node("LevelManager")


func _ready():
	#target_position.y = target_position.y * fish.fish_size		
	pass
func _physics_process(_delta):
	if position != Vector3.ZERO:
		position = Vector3.ZERO
	global_position = fish.global_position
	global_basis = fish.global_basis
	
#	global_position = mesh_instance_3d.global_position
#	global_rotation = mesh_instance_3d.global_rotation
	if is_colliding(): #not running for some reason?
		pass
		#var hit_object = get_collider()
		#if hit_object.get_collision_layer_value(4):
			
			#level_manager.died=true
			#fish.re_sphere()
			#fish.global_position = level_manager.latestcheckpoint 
			
			
			#print("death")
	'''
	if is_colliding():
		if name == "GroundCheckRayPlus":
			fish.raycheckgroundedplus = true
		elif name == "GroundCheckRayMinus":
			fish.raycheckgroundedminus = true
		
		var hit_object = get_collider()
		if hit_object.get_collision_layer_value(4):
			
			fish.global_position = level_manager.latestcheckpoint 
			print("death")
			
			
			
			if fish.global_position != Vector3(0,0,0):
				fish.can_move = false
				fish.level_finished = true
				
				fish.angular_velocity.x = clamp(fish.angular_velocity.x,-5,5)
				fish.angular_velocity.y = clamp(fish.angular_velocity.y,-5,5)
				fish.angular_velocity.z = clamp(fish.angular_velocity.z,-5,5)
				#marble.linear_velocity = Vector3.ZERO
				
				fish.level_finish_cooldown_tickstate = -1
				fish.level_finish_cooldown=fish.level_finish_cooldown_max
			else:
				fish.angular_velocity = Vector3.ZERO
				fish.linear_velocity = Vector3.ZERO
			
	else:
		if name == "GroundCheckRayPlus":
			fish.raycheckgroundedplus = false
		elif name == "GroundCheckRayMinus":
			fish.raycheckgroundedminus = false
	'''
