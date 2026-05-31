extends RigidBody3D
class_name Marble

@export var movement_speed: float = 500.0 #385.0
@export var max_velocity: float = 15
@export var jump_power : float = 1.5 #2 default
@export var jump_charge_bonus : float = 1
@export var finish_deceleration : float = .25
@export var friction_base : float = 0.35

#@export var manual_force_magnitude: float = 1200.0
@export var manual_speed_threshold: float = 1.0

@export var torque_magnitude: float = 1

@export var downhill_boost_power: float = 1000.0

@export var absolute_top_speed : float = 5.0

var dontbreakframes : int = -1
@export var simple_break_threshold : float = 2
@export var destruction_threshold : float = 1.5
@export var bump_sphere_delay : int = 6
var speed_min_destruction : float = 1.0
var bump_sphere : int = 0
var bump_sphere_speed : float = 0
var bump_sphere_dir : Vector3 = Vector3(0,0,0)
@export var speed_reduction_min_destruction : float = 0.5
@export var veldif_shatterpoint : float = 0.75

var brokensphere : int = 0
var shattercount : int = 0

@export var supertorpedo_threshold : int = 200

var skidmode : float = -1 #when activated, goes down until stops at 0. -1 means deactivated
var skidmodemax : float = 45 #max jumphold
var uptilt : float = 0

var ismarbletopmanualspeeding : int = 0
var ismarbletoptorquing : int = 0
var ismarbletopdownhillspeeding : int = 0

var level_finish_cooldown : int = 0
var level_finish_cooldown_max : int = 100
var level_finish_cooldown_tickstate : int = 0 # -1 = just got in, 0 = idle, 1 = just got out (dont get in again)

@onready var camera_3d: Camera3D = $"../CameraContainer/hRot/vRot/SpringArm3D/Camera3D"
@onready var camera_container: Node3D = $"../CameraContainer"
@onready var finishcheckray: RayCast3D = $"../FinishCheckRay"
@onready var level_manager: LevelManager = $"../../../LevelManager"
@onready var debug_label: Label = $"../DebugCanvas/DebugLabel"
@onready var fish_test_1: Node3D = $"../flatfish"
@onready var fish_test_1_animation_player: AnimationPlayer = $"../flatfish/AnimationPlayer"
@onready var fish_test_1_animation_tree: AnimationTree = $"../flatfish/AnimationTree"

var facingfish : Vector3
var last_facingfish: Vector3 = Vector3.FORWARD
var last_stable_basis: Basis = Basis.IDENTITY

var raycheckgrounded = false
var contactgrounded = false
var groundtimer : int = 0
@export var coyotetime : int = 3 #in frames
var grounded = false
var can_move = true
var level_finished = false

var am_finishtouching = false

var last_linear_velocity : Vector3 = linear_velocity

@export var fish_anim_rotation_speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if dontbreakframes>=0:
		dontbreakframes-=1
	'''if bump_sphere>0:
		print("bump -1")
		bump_sphere-=1
		if bump_sphere>0:
			var bump_sphere_speed_diff : float = bump_sphere_speed - state.linear_velocity.length()
			var veldir = linear_velocity
			#X: Positive is Right, Negative is Left.
			#Y: Positive is Up, Negative is Down.
			#Z: Positive is "Back" (toward the camera), Negative is "Forward" (away from the camera).
			var vdx : float = maxf(veldir.x,bump_sphere_dir.x) - minf(veldir.x,bump_sphere_dir.x)
			var vdy : float = maxf(veldir.y,bump_sphere_dir.y) - minf(veldir.y,bump_sphere_dir.y)
			var vdz : float = maxf(veldir.z,bump_sphere_dir.z) - minf(veldir.z,bump_sphere_dir.z)
			print("vdx: "+str(vdx)+" vdy: "+str(vdy)+" vdz: "+str(vdz))
			
			
			#if veldir.y<0 and grounded==false:
				#vdy*=2
				#print ("vdycorrected, GOING DOWN: "+str(vdy))
			#elif veldir.y>0:
				#vdy/=2
				#print ("vdycorrected, GOING UP: "+str(vdy))
			#print("xdirdif: prev"+str(bump_sphere_dir.x)+" new"+str(veldir.x))
			print("bump sphere speed diff: "+str(bump_sphere_speed_diff)+" <?"+str(speed_reduction_min_destruction))
			print("vds :"+str(vdx+vdy+vdz)+" <? "+str(veldif_shatterpoint))
			if vdx+vdy+vdz > veldif_shatterpoint and bump_sphere_speed_diff>speed_reduction_min_destruction:				
				print("nobreak")
				destroy_sphere()
		
		if bump_sphere==0:
			bump_sphere_speed= 0
			bump_sphere_dir= Vector3(0,0,0)
	'''
	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			# Get the velocity and the normal of the collision
			var velocity_at_impact = state.linear_velocity
			var contact_normal = state.get_contact_local_normal(i)
			
			var impact_speed = abs(velocity_at_impact.dot(contact_normal))
			var is_floorlike = contact_normal.dot(Vector3.UP)
			
			var alignment = velocity_at_impact.normalized().dot(contact_normal)
			
			if impact_speed > 0.3:
				print("alignment: "+str(alignment))
				print(str(impact_speed)+": impact_speed <? "+str(simple_break_threshold / abs(alignment)))
				if level_finished==false and dontbreakframes==-1 and (impact_speed > simple_break_threshold / abs(alignment)):
					destroy_sphere()
			
			
			
			if contact_normal.dot(Vector3.UP) > 0.5: # Touching something relatively flat
				contactgrounded = true
			else:
				contactgrounded = false
			# Calculate how much velocity was directed into the surface
			# dot product returns 1.0 if perfectly aligned, 0.0 if perpendicular
			'''var impact_speed = abs(velocity_at_impact.dot(contact_normal))
			#var impact_momentum = impact_speed * mass
			if impact_speed>0.5:
				print("impact spd: " + str(snapped(impact_speed,0.001)) )#+"impact mom: " + str(impact_momentum)) 
				print("bump spd: "+str(state.linear_velocity.length()))
			if impact_speed > destruction_threshold and bump_sphere_speed<state.linear_velocity.length() and state.linear_velocity.length() > speed_min_destruction:
				bump_sphere=bump_sphere_delay 
				print("bump"+str(bump_sphere))
				bump_sphere_speed=state.linear_velocity.length()
				bump_sphere_dir = state.linear_velocity
				print("bump sphere dir: "+str(bump_sphere_dir))
				
				
				break
			'''	
	else:
		contactgrounded = false

func setup_ball_from_fish(fishnode : Node3D, livel : Vector3, anvel : Vector3, pos : Vector3, gpos : Vector3, rot : Vector3, grot : Vector3, sca : Vector3 \
, crh : float , crv : float):
	camera_container.camrot_h = crh
	camera_container.camrot_v = crv
	
	linear_velocity = livel
	#angular_velocity = anvel
	global_position = gpos
	position = pos
	rotation = rot 
	
	global_rotation = grot #+ Quaternion(Vector3.FORWARD, deg_to_rad(90))
	
	
	#fish_size = sca.x #this is vector3
	#animation_player.play("swim")
	print("ok")


var new_fish_scene = preload("res://Objects/Player/fish_test.tscn")


		
func destroy_sphere():
	print("SHATTERED")
	brokensphere = 2
	shattercount+=1
	var new_fish = new_fish_scene.instantiate()#fish_test_1.
	var fish_body = new_fish.get_node("Feesh")
	#get_parent().
	get_tree().root.find_child("Environment", true, false).add_child(new_fish)
	fish_body.setup_fish_from_ball(self,last_linear_velocity,angular_velocity,fish_test_1.position+Vector3(0,0.3,0),fish_test_1.global_position,fish_test_1.rotation,fish_test_1.global_rotation,fish_test_1.scale, \
	camera_container.camrot_h,camera_container.camrot_v,fish_test_1.supertorpedo_mode,fish_test_1.supertorpedo_speed,fish_test_1.max_supertorpedo_speed,skidmode, facingfish, uptilt)
	
	owner.queue_free()
	
func _physics_process(delta):
	last_linear_velocity = linear_velocity
	
	if brokensphere>0:
		brokensphere-=1
	
				
	if raycheckgrounded == true and contactgrounded == true:
		groundtimer=coyotetime
	else:
		groundtimer=clamp(groundtimer-1,0,coyotetime)
	
	if groundtimer > 0: 
		grounded = true
		gravity_scale=1
		linear_damp=0.25
	else:
		grounded = false
		gravity_scale=0.5
		linear_damp=0
	#print("can move",can_move)	
	#print("level finish cooldown tickstate",level_finish_cooldown_tickstate)	
	#print("level finished",level_finished)	
	
	if can_move:
		movement_torque(delta)
		movement(delta)
		
	#dif level_finished:
	#	gravity_scale = move_toward(gravity_scale,0.0,finish_deceleration * delta)
	
	if level_finish_cooldown_tickstate != 0:
		#print(str(level_finish_cooldown))
		level_finish_cooldown=clamp(level_finish_cooldown-1,0,level_finish_cooldown_max)
		if level_finish_cooldown == 0 and level_finish_cooldown_tickstate!=0:
			level_finish_cooldown_tickstate = 0
			#print("papai")
	
	if level_finish_cooldown == 0 and level_finished and can_move == false and am_finishtouching == true:
		var target_collided = finishcheckray.get_collider()
		var collided_area = target_collided.get_node("../FinishArea")
		global_position = collided_area.global_position + collided_area.gravity_point_center
		level_manager.latestcheckpoint = global_position
			
		
				
	#linear_velocity.x = clamp(linear_velocity.x, -max_velocity, max_velocity)
	
	if Input.is_action_just_pressed("jump"):
		if skidmode<=0:
			skidmode=skidmodemax
	
	if Input.is_action_pressed("jump"):
		if skidmode>0:
			skidmode-=1
	elif !Input.is_action_just_released("jump"):
		skidmode=-1
		pass
	if skidmode>0:
		#angular_velocity *= 0.9
		pass
		
	#physics_material_override.friction = friction_base + (skidmode/10)
		
	if Input.is_action_just_released("jump") and skidmode>=0 and (grounded or level_finished) and level_finish_cooldown_tickstate!=-1:
		jump()
		dontbreakframes=1
		print("jump")
		skidmode=-1
		if level_finish_cooldown_tickstate==0 and level_finished == true and can_move == false:
			level_finish_cooldown_tickstate = 1
			level_finish_cooldown = level_finish_cooldown_max
			level_finished = false
			can_move = true
			
			var zones = get_tree().get_nodes_in_group("finishareas")
			for zone in zones:
				zone.gravity_space_override = Area3D.SPACE_OVERRIDE_DISABLED
				zone.linear_damp_space_override = Area3D.SPACE_OVERRIDE_DISABLED
				zone.angular_damp_space_override = Area3D.SPACE_OVERRIDE_DISABLED
	
		
	pass

func movement_torque(delta):
	var f_input = Input.get_action_raw_strength("forward") - Input.get_action_raw_strength("backward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	
	if Input.is_action_just_pressed("break") == true and level_finished==false and dontbreakframes==-1:
		destroy_sphere()
	
	#var as_d_input = Input.get_action_raw_strength("ANGULAR speed down") - Input.get_action_raw_strength("ANGULAR speed up")
	#var ls_d_input = Input.get_action_raw_strength("LINEAR speed down") - Input.get_action_raw_strength("LINEAR speed up")
	
	var camera_transform = camera_3d.get_camera_transform()
	
	var relative_camera_direction_z = camera_transform.basis.z.normalized()
	#print("z :"+str(relative_camera_direction_z))	
	var relative_camera_direction_x = camera_transform.basis.x.normalized()
	#print("x: "+str(relative_camera_direction_x))
	
	var direction_f = f_input * relative_camera_direction_z
	var direction_h = h_input * relative_camera_direction_x

	var move_direction = (relative_camera_direction_z * f_input + relative_camera_direction_x * h_input).normalized()
	move_direction.y = 0 # Keep force horizontal
	
	
	# 1. Find the 'axle' (perpendicular to movement and up)
	# If move_direction is Forward, torque_axis will be Right/Left
	var torque_axis : Vector3
	#if move_direction.length() > 0:
	#	torque_axis = move_direction.cross(Vector3.UP)
	#else:
	#	torque_axis = linear_velocity.normalized()
	# POINT FISH AT MOVE DIRECTION
	# 1. Create a target transformation looking at the movement
	var rotfish_correction = Quaternion(Vector3.FORWARD, deg_to_rad(90))
	
	uptilt = skidmodemax-skidmode
	if skidmode==-1:
		uptilt =0
	
	
	if move_direction.length() > 0:
		var target_transform = fish_test_1.global_transform.looking_at(fish_test_1.global_position + move_direction, Vector3.UP)
		last_stable_basis = target_transform.basis
		
	#fish_test_1.global_transform.looking_at(fish_test_1.global_position + move_direction, Vector3.UP)
		
	else:
		
		pass
	var pitch_quat = Quaternion(Vector3.RIGHT, deg_to_rad(uptilt))
	#NEW
	var turbo_roll_quat = Quaternion(Vector3.FORWARD, deg_to_rad(fish_test_1.torpedo_correction_turbo))
	var target_quat = Quaternion(Vector3.UP, PI) * last_stable_basis.get_rotation_quaternion() * pitch_quat * rotfish_correction * turbo_roll_quat
	if fish_test_1.supertorpedo_speed==fish_test_1.max_supertorpedo_speed or fish_test_1.supertorpedo_speed==-fish_test_1.max_supertorpedo_speed:
		fish_test_1.quaternion = target_quat
	else:
		fish_test_1.quaternion = fish_test_1.quaternion.slerp(target_quat, fish_anim_rotation_speed * delta)
	
	facingfish = Vector3(fish_test_1.nose_3d.global_position - fish_test_1.global_position).normalized()
	#facingfish = -last_stable_basis.z.normalized()
	
	# clean_basis.z.normalized()
	# 2. Check your speed limit (using the dot product logic from before)
	var current_speed_in_direction = linear_velocity.dot(move_direction*-1)
	
	if current_speed_in_direction < manual_speed_threshold and linear_velocity.length() < absolute_top_speed:
		# 3. Apply torque instead of central force
		# We use negative torque_axis because of the way Godot's axes are oriented
		apply_torque(torque_axis * torque_magnitude)
		'''/(2+skidmode)'''
		ismarbletoptorquing = 0
	else: 
		ismarbletoptorquing = 1

func movement(delta):
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	
	var as_d_input = Input.get_action_raw_strength("ANGULAR speed down") - Input.get_action_raw_strength("ANGULAR speed up")
	var ls_d_input = Input.get_action_raw_strength("LINEAR speed down") - Input.get_action_raw_strength("LINEAR speed up")
	
	
	
	var camera_transform = camera_3d.get_camera_transform()
	
	var relative_camera_direction_z = camera_transform.basis.z.normalized()
	var relative_camera_direction_x = camera_transform.basis.x.normalized()
	
	var direction_f = f_input * relative_camera_direction_z
	var direction_h = h_input * relative_camera_direction_x
	
	var move_direction = (relative_camera_direction_z * f_input + relative_camera_direction_x * h_input).normalized()
	move_direction.y = 0 # Keep force horizontal
		
	
		
	if move_direction.length() > 0:
		# 2. Calculate current velocity along the move direction
		# .dot() returns how much 'linear_velocity' aligns with 'move_direction'
		var current_speed_in_direction = linear_velocity.dot(move_direction)
		
		# set fish anim speed
		#fish_test_1_animation_player.speed_scale=current_speed_in_direction * 3
		fish_test_1_animation_tree.set("parameters/Swim/TimeScale/scale", current_speed_in_direction * 1)
		#print(str(fish_test_1_animation_player.speed_scale))
		
		var speed_diff = manual_speed_threshold - current_speed_in_direction
		var force_multiplier = clamp(speed_diff / 2.0, 0.0, 1.0) #+ abs(skidmode/10)
		
		# 3. Only apply force if we haven't hit the manual threshold
		if current_speed_in_direction < manual_speed_threshold :
			apply_central_force(move_direction * movement_speed * force_multiplier * delta) #manual_force_magnitude
			ismarbletopmanualspeeding = 0
		else:
			ismarbletopmanualspeeding = 1
	#apply_central_force(direction_f * movement_speed * delta)
	#apply_central_force(direction_h * movement_speed * delta)
	 
	
		
		var downhill_factor = linear_velocity.normalized().dot(Vector3.DOWN)
		# downhill_factor will be > 0 if we are descending
		if downhill_factor > 0.1 and grounded and linear_velocity.length() < absolute_top_speed: 
		# Apply extra force in the direction the ball is ALREADY moving
		# This 'helps' the gravity along
			var boost_vector = linear_velocity.normalized() * downhill_boost_power * downhill_factor
			apply_central_force(boost_vector * delta)
			ismarbletopdownhillspeeding = 0
		else:
			ismarbletopdownhillspeeding = 1
	pass
	
func jump():
	apply_central_impulse(Vector3.UP * (jump_power + ((skidmodemax+1)-skidmode)*jump_charge_bonus*0.01))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
