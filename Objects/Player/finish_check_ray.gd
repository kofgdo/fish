extends RayCast3D

@onready var marble: RigidBody3D = $"../Marble"
@onready var mesh_instance_3d: MeshInstance3D = $"../Marble/MeshInstance3D"
@onready var level_manager: LevelManager = get_tree().current_scene.get_node("LevelManager")
		
func _physics_process(_delta):
	global_position = mesh_instance_3d.global_position
				
	
	if is_colliding():
		var hit_object = get_collider()
		if hit_object.get_collision_layer_value(3):
			print("validcheckpoint: "+str(hit_object.owner.validcheckpoint))
			print("died :"+str(level_manager.died))
			print("lfct: "+str(marble.level_finish_cooldown_tickstate))
		if hit_object.get_collision_layer_value(3) and hit_object.owner.validcheckpoint==true \
		and (level_manager.finishid!=hit_object.owner.finishid or level_manager.died==true) \
		and marble.level_finish_cooldown_tickstate==0:
			
			hit_object.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
			hit_object.linear_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
			hit_object.angular_damp_space_override = Area3D.SPACE_OVERRIDE_REPLACE
			
			marble.am_finishtouching = true
			print("huh?")
			level_manager.finishid=hit_object.owner.finishid
			level_manager.died=false
			#below this was previously in the object entered signal
			marble.can_move = false
			marble.level_finished = true
			
			marble.angular_velocity.x = clamp(marble.angular_velocity.x,-5,5)
			marble.angular_velocity.y = clamp(marble.angular_velocity.y,-5,5)
			marble.angular_velocity.z = clamp(marble.angular_velocity.z,-5,5)
			marble.linear_velocity = Vector3.ZERO
			
			marble.level_finish_cooldown_tickstate = -1
			marble.level_finish_cooldown=marble.level_finish_cooldown_max
		#print("amfinishtouching")
	else:
		marble.am_finishtouching = false
	
