extends ShapeCast3D

@onready var marble: RigidBody3D = $"../Marble"
@onready var mesh_instance_3d: MeshInstance3D = $"../Marble/MeshInstance3D"
@onready var level_manager: LevelManager = $"../../../LevelManager"

func _physics_process(_delta):
	global_position = mesh_instance_3d.global_position
	
	if is_colliding():
		marble.raycheckgrounded = true
		var hit_object = get_collider(0)
		if hit_object.get_collision_layer_value(4):
			
			marble.global_position = level_manager.latestcheckpoint 
			print("death")
			#marble.level_finish_cooldown_tickstate = 0
			level_manager.died=true
			
			
			if marble.global_position != Vector3(0,0,0):
				marble.can_move = false
				marble.level_finished = true
				
				marble.angular_velocity.x = clamp(marble.angular_velocity.x,-5,5)
				marble.angular_velocity.y = clamp(marble.angular_velocity.y,-5,5)
				marble.angular_velocity.z = clamp(marble.angular_velocity.z,-5,5)
				marble.linear_velocity = Vector3.ZERO
				
				#marble.level_finish_cooldown_tickstate = -1
				#marble.level_finish_cooldown=marble.level_finish_cooldown_max
			else:
				marble.angular_velocity = Vector3.ZERO
				marble.linear_velocity = Vector3.ZERO
			
	else:
		marble.raycheckgrounded = false
