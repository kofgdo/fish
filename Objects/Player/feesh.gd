extends RigidBody3D
class_name Fish

var init_livel
var init_supertorpspeed
var init_maxsupertorpspeed
var init_facing
var init_tiltup
var init_crh
var init_crv
var init : bool = true

#@export var movement_speed: float = 500.0 #385.0
@export var max_velocity: float = 15
@export var jump_power : float = 5 
@export var jump_power_air_factor : float = 1#0.3
var jump_weaken : float = 1.0
@export var jump_weaken_factor: float = 2
@export var supertorpedo_drill_speed : float = 50
@export var supertorpedo_drill_turnrate : float = 5
@export var supertorpedo_velimit : float = 0.5
var supertorpedo_auto : bool = false
#@export var finish_deceleration : float = .25
@export var scoot_power : float = 4
var scooting : int = 0
@export var scoot_cooldown : int = 15

@export var passive_scoot_power : float = 0.4

#@export var fish_turn_speed : float = 1.5

@export var fish_size : float = 0.1 #default 0.05

#@export var manual_force_magnitude: float = 1200.0
@export var manual_speed_threshold: float = 1.0

#@export var torque_magnitude: float = 0.02 #unused
@export var pageturn_speed : float = 2#1
@export var boomerangturn_speed : float = 3#3
@export var torpedoturn_speed : float = 0.3#0.3
@export var fish_anim_rotation_speed: float = 10.0
#@export var ground_torque_dampen : float = 5.0 #x100

@export var land_vspeed_dampen : float = 0.1 #multiplier, 0 to 1 (0 cuts all speed)
@export var land_vspeed_dampen_cooldown_max : int = 30
var land_vspeed_dampen_cooldown : int = 0

var air_swim_mode : bool = false
var flying_fish : bool = false

var air_swim_speed : float = 2

var last_linear_velocity : Vector3 = linear_velocity

var dry : bool = false 
@export var stick_force : float = 50.0

var plus : bool = false
var minus : bool = false

@export var destruction_threshold : float = 1.5

var level_finish_cooldown : int = 0
var level_finish_cooldown_max : int = 100
var level_finish_cooldown_tickstate : int = 0 # -1 = just got in, 0 = idle, 1 = just got out (dont get in again)

@onready var camera_3d: Camera3D = $"../CameraContainer/hRot/vRot/SpringArm3D/Camera3D"
@onready var camera_container: Node3D = $"../CameraContainer"
#@onready var finishcheckray: ShapeCast3D = $"fish3D(1)/FinishCheckRay"
@onready var finishcheckray: ShapeCast3D = $FinishCheckRay
@onready var level_manager: LevelManager = $"../../../LevelManager"
@onready var debug_label: Label = $"../DebugCanvas/DebugLabel"
@onready var fish_test_1: Node3D = $flatfish
@onready var animation_player: AnimationPlayer = $flatfish/AnimationPlayer
@onready var animation_tree: AnimationTree = $flatfish/AnimationTree
@onready var ground_check_ray_plus: RayCast3D = $GroundCheckRayPlus
@onready var ground_check_ray_minus: RayCast3D = $GroundCheckRayMinus
@onready var playback = animation_tree["parameters/playback"]
@onready var nose_3d: Node3D = $flatfish/Armature/Skeleton3D/Cube/Nose3D

var flapstate : int = 0 # 0 = idle, 1 = loading flap, -1 = flap cooldown 

var raycheckgroundedplus : bool = false
var raycheckgroundedminus : bool = false
var hogginground : int = 0
var hogginground_cooldownmax : int = 30
var contactgrounded = false
var groundtimer : int = 0
@export var coyotetime : int = 3 #in frames
var grounded = false
var can_move = true
var level_finished = false

var am_finishtouching = false

var local_x = global_transform.basis.x
var local_y = global_transform.basis.y
var local_z = global_transform.basis.z

var torpedo_max_buffer : int = 31
var torpedo_speed : float = 0.1

var supertorpedo_mode : int = -1
var supertorpedo_angle : float = 0
var supertorpedo_accel : float = 0.0125
var supertorpedo_speed : float = 0
var supertorpedo_speed_deaccel : float = 0.1
var max_supertorpedo_speed : float = 0.5#0.35
var supertorpedo_buffer : int = 0
var supertorpedo_max_buffer : int = 30
var supertorpedo_fromball_buffer : int = 20
var supertorpedo_current_pitch_angle: float = 0.0
var total_supertorpedo_roll: float = 0.0
var supertorpedo_superspeedfactor: float = 50.0
var supertorpedo_plummetcel: float = 1.0
var supertorpedo_stallcel: float = 10.0
var supertorpedo_drill_vturnfactor=0.5

var torpedo_target = 0 # 90 degrees RIGHT or LEFT
var torpedo_left = -1
var torpedo_right = -1
# -1 = NOT PRESSED. 1 = PRESSED. 0 = RELEASED, TILTED 
var torpedo_snapping : int = -1
var torpedo_snapping_max : int = 5

var half_length = 2.4/6 #*scale.z  # tweak to match fish size
var half_width = 1.1/6 #*scale.x 
var half_height = 2/6 #*scale.y
var top = local_y * half_height
var bottom = -local_y * half_height

#@export var new_ball_scene = preload("res://Objects/Player/PlayerBall.tscn")

func re_sphere():
	print("RESPHERE")
	
	var new_ball_scene = load("res://Objects/Player/PlayerBall.tscn")
	print("Scene is: ", new_ball_scene)
	if new_ball_scene == null:
		print("CRITICAL: The export variable 'new_ball_scene' is empty!")
	var new_ball = new_ball_scene.instantiate()#fish_test_1.
	if new_ball == null:
		print("CRITICAL: Instantiate returned null. The scene file might be corrupt or missing.")
		return
	#print("Instance created! Printing tree structure:")
	#new_ball.print_tree_pretty()	
	var ball_body = new_ball.get_node("Marble")
	#get_parent().
	get_tree().root.find_child("Environment", true, false).add_child(new_ball)
	ball_body.setup_ball_from_fish(self,last_linear_velocity,angular_velocity,fish_test_1.position+Vector3(0,0.3,0),fish_test_1.global_position,fish_test_1.rotation,fish_test_1.global_rotation,fish_test_1.scale,camera_container.camrot_h,camera_container.camrot_v)
	
	owner.queue_free()
	
func setup_fish_from_ball(ballnode : Node3D, livel : Vector3, anvel : Vector3, pos : Vector3, gpos : Vector3, rot : Vector3, grot : Vector3, sca : Vector3 \
, crh : float , crv : float, supertorpmode : int, supertorpspeed : float, supertorpmaxspeed : float, skidangle : int, facing : Vector3, tiltup : float):
		
	#camera_container.cambigsmooth=90
	#camera_container.camlock=5
	
	rotation = rot 
	
	global_rotation = grot #+ Quaternion(Vector3.FORWARD, deg_to_rad(90))
	
	if supertorpspeed >= supertorpmaxspeed or supertorpspeed<=-supertorpmaxspeed:
		#supertorpedo_auto=true
		
		pass
		
	#angular_velocity = anvel
	global_position = gpos
	position = pos
	
	
	
	fish_size = sca.x #this is vector3
	
	init = true
	init_crh = crh
	init_crv = crv
	init_livel = livel
	init_tiltup = tiltup
	init_facing = facing
	init_supertorpspeed = abs(supertorpspeed)
	init_maxsupertorpspeed = supertorpmaxspeed
	
	print(str(init_supertorpspeed)  + "LAUNCH")
	
	playback.travel("Swim")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	camera_3d.make_current()
	scale = Vector3(fish_size,fish_size,fish_size)
	#get_node("fish3D(1)").scale = Vector3(fish_size,fish_size,fish_size)
	




func _integrate_forces(state: PhysicsDirectBodyState3D):
	land_vspeed_dampen_cooldown=clamp(land_vspeed_dampen_cooldown-1,0,land_vspeed_dampen_cooldown_max)
	
	if init:
		camera_container.camrot_h = init_crh
		camera_container.camrot_v = init_crv
		if init_supertorpspeed!=init_maxsupertorpspeed:
			var fbvelen = init_livel.length()
			var fbmod = init_tiltup/90 # 1 = vertical, 0 = normal
			var fbfallspeed = init_livel.y
			var fbhvel = Vector3(init_livel.x,0,init_livel.z)
			var fbhspeed = fbhvel.length()
			var fbhdir = fbhvel.normalized()
			
			if fbvelen > 0.05:
				var fbforward = fbhdir * (fbhspeed * (1.0 - fbmod))
				var fbupward = Vector3.UP * (fbmod * fbhspeed)
				linear_velocity = (Vector3.UP * fbfallspeed) + fbforward + fbupward
				
			else:
				linear_velocity = init_livel
		else:
			linear_velocity += init_facing * init_supertorpspeed/3 #10 = break speedadd
		init=false
		
	var f_input = Input.get_action_raw_strength("forward") - Input.get_action_raw_strength("backward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	#GOGO
	if supertorpedo_auto:
		# 1. SAVE THE ORIGINAL SCALE
		var original_scale = state.transform.basis.get_scale()
		
		# --- STRIP THE TORPEDO ROLL TO CALCULATE STEERING SAFELY ---
		var current_fwd = -state.transform.basis.z.normalized()
		
		# 2. Track our pitch angle directly using math instead of vectors
		var current_pitch_rad = asin(current_fwd.y)
		
		# 3. Calculate the player's intended pitch change
		var pitch_change = f_input * supertorpedo_drill_turnrate*supertorpedo_drill_vturnfactor * state.step
		
		# 4. STRICT CLAMP: Set a hard limit at ~70 degrees (1.22 radians)
		var target_pitch_rad = clamp(current_pitch_rad + pitch_change, -1.22, 1.22)
		
		# 5. Calculate global horizontal steering (Yaw around Vector3.UP)
		var yaw_quat = Quaternion(Vector3.UP, h_input * supertorpedo_drill_turnrate * state.step)
		
		# 6. Apply yaw to our current orientation FIRST
		var rotated_quat = yaw_quat * state.transform.basis.get_rotation_quaternion()
		var temporary_basis = Basis(rotated_quat)
		
		# 7. Reconstruct a clean, un-rolled forward heading on the ground
		var temp_fwd = -temporary_basis.z.normalized()
		var flat_heading = Vector3(temp_fwd.x, 0.0, temp_fwd.z).normalized()
		if flat_heading.is_zero_approx():
			flat_heading = Vector3.FORWARD
			
		var steady_right_axis = Vector3.UP.cross(flat_heading).normalized()
		
		# 8. BUILD THE FINAL DIRECTION VECTOR
		var final_fwd = (flat_heading * cos(target_pitch_rad)) + (Vector3.UP * sin(target_pitch_rad))
		final_fwd = final_fwd.normalized()
		
		# 9. RECONSTRUCT THE STEERING BASIS MATRIX FROM SCRATCH
		var new_z = -final_fwd
		var new_y = steady_right_axis.cross(new_z).normalized()
		var new_x = new_y.cross(new_z).normalized()
		
		var clean_steering_basis = Basis(new_x, new_y, new_z)
		
		# --- FIXED TORPEDO ROLL MECHANIC ---
		
		# 10. Accumulate the spinning angle over time so it never resets
		total_supertorpedo_roll -= supertorpedo_speed*supertorpedo_superspeedfactor * state.step
		
		# Wrap the angle around 360 degrees (2*PI radians) to keep the math clean
		total_supertorpedo_roll = fmod(total_supertorpedo_roll, TAU)
		
		# 11. Create a roll quaternion using the TOTAL accumulated angle
		var roll_quat = Quaternion(Vector3.FORWARD, total_supertorpedo_roll)
		
		# 12. Combine them: Clean global heading * accumulated local roll
		state.transform.basis = clean_steering_basis * Basis(roll_quat)
		
		# 13. Restore the scale safely
		state.transform.basis = state.transform.basis.scaled(original_scale)
		
		# 6. GET THE NEW NOSE DIRECTION
		var raw_fwd = -state.transform.basis.z.normalized()
		
		# 7. CALCULATE HORIZONTAL SPEED ONLY 
		var horizontal_velocity = Vector3(state.linear_velocity.x, 0.0, state.linear_velocity.z)
		var current_horizontal_speed = horizontal_velocity.length()
		
		if current_horizontal_speed < 0.01:
			current_horizontal_speed = 0.01 
		
		# 8. APPLY THE STALL & DIVE INFLUENCE
		var pitch_factor = raw_fwd.y
		var adjusted_speed = current_horizontal_speed
		'''
		if pitch_factor > 0:
			adjusted_speed -= pitch_factor * supertorpedo_plummetcel
		else:
			adjusted_speed -= pitch_factor * supertorpedo_stallcel
		'''
		adjusted_speed = max(adjusted_speed, 2.0)
		
		# 9. APPLY THE HORIZONTAL MOVEMENTS
		var flat_fwd = Vector3(raw_fwd.x, 0.0, raw_fwd.z).normalized()
		state.linear_velocity.x = flat_fwd.x * adjusted_speed
		state.linear_velocity.z = flat_fwd.z * adjusted_speed
		
		# 10. APPLY THE VERTICAL MOMENTUM 
		var gravity_modifier = pitch_factor * 5.0
		state.linear_velocity.y += (gravity_modifier * state.step)
		
		# Kill the gyroscopic wobble
		state.angular_velocity = Vector3.ZERO
	'''
	var current_speed = state.linear_velocity.length()
	var fwd_dir = -global_basis.z.normalized()
	if supertorpedo_auto:
		var yaw_rotation = Basis(Vector3.UP, h_input * supertorpedo_drill_turnrate * state.step)
		var pitch_rotation = Basis(Vector3.RIGHT, f_input * supertorpedo_drill_turnrate * state.step)
		var raw_fwd = -state.transform.basis.z
		var flat_fwd = Vector3(raw_fwd.x, 0.0, raw_fwd.z).normalized()
		var current_y_velocity = state.linear_velocity.y
		state.linear_velocity.x = flat_fwd.x * current_speed
		state.linear_velocity.z = flat_fwd.z * current_speed
		state.linear_velocity.y = current_y_velocity
		
		state.transform.basis = yaw_rotation * (pitch_rotation * state.transform.basis)# * roll_rotation
		
		#var forward_dir = -state.transform.basis.z.normalized()
		#state.transform.basis = state.transform.basis.orthonormalized() # Keep math clean
		#state.linear_velocity = fwd_dir * current_speed
		state.angular_velocity = Vector3.ZERO
	'''
	
	
	'''if (ground_check_ray_minus.is_colliding() or ground_check_ray_plus.is_colliding()) and hogginground == 0:
		var normal
		if ground_check_ray_minus.is_colliding() and raycheckgroundedminus == true:
			print("minus")
			normal = ground_check_ray_minus.get_collision_normal()
		if ground_check_ray_plus.is_colliding() and raycheckgroundedplus == true:
			normal = ground_check_ray_plus.get_collision_normal()
			print("plus")
		var current_velocity = state.linear_velocity
		
		var sliding_velocity = current_velocity - normal * current_velocity.dot(normal)
		state.linear_velocity = sliding_velocity'''
	if hogginground > 0:
		hogginground=clamp(hogginground-1,0,hogginground_cooldownmax)	
	if ground_check_ray_plus.is_colliding() and hogginground == 0:
		var normal = ground_check_ray_plus.get_collision_normal()
		
		plus = true
		# THIS IS TO STICK TO RAILS
		#'''
		#if Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")==0:
		var current_velocity = state.linear_velocity
		var sliding_velocity = current_velocity - normal * current_velocity.dot(normal)
		state.linear_velocity = sliding_velocity
		#'''
	else:
		plus = false
	if ground_check_ray_minus.is_colliding() and hogginground == 0:
		var normal = ground_check_ray_minus.get_collision_normal()
		
		minus = true
		# THIS IS TO STICK TO RAILS
		'''
		var current_velocity = state.linear_velocity
		var sliding_velocity = current_velocity - normal * current_velocity.dot(normal)
		state.linear_velocity = sliding_velocity
		'''
	else:
		minus = false
	if state.get_contact_count() > 0:
		if playback.get_current_node() == "Swim":
			playback.travel("Idle")
		for i in range(state.get_contact_count()):
			
			"scale"
			# NEW
			# Get the velocity and the normal of the collision
			var velocity_at_impact = state.linear_velocity
			var contact_normal = state.get_contact_local_normal(i)
			# old code for dulling yspeed when coming down
			if linear_velocity.y<0 and contact_normal.dot(Vector3.UP) > 0.5: # Touching something relatively flat
				'''if contactgrounded == false and land_vspeed_dampen_cooldown==0 and dry == false:
					print("railbrake") # issue: keeps bouncing sometimes
					land_vspeed_dampen_cooldown=land_vspeed_dampen_cooldown_max
					linear_velocity.y*=land_vspeed_dampen # reduce vertical fall when touching ground to stop bounce
					'''
				contactgrounded = true
			else:
				contactgrounded = false
			# Calculate how much velocity was directed into the surface
			# dot product returns 1.0 if perfectly aligned, 0.0 if perpendicular
			#var impact_speed = abs(velocity_at_impact.dot(contact_normal))
			#var impact_momentum = impact_speed * mass
			#if impact_speed>1:
			#	print("impact spd: " + str(snapped(impact_speed,0.01)) )#+"impact mom: " + str(impact_momentum)) 
			#if impact_momentum > destruction_threshold:
			#	destroy_sphere()
			#	break
	else:
		contactgrounded = false
func kill_fish():
	print("asphyxiated")

func _physics_process(delta):
	last_linear_velocity = linear_velocity
	#region torpedo	
	var torpedo_left_input = Input.get_action_raw_strength("up")
	var torpedo_right_input = Input.get_action_raw_strength("down")
	var break_input = Input.get_action_raw_strength("break")
	supertorpedo_fromball_buffer=clamp(supertorpedo_fromball_buffer-1,-600,60)
	if supertorpedo_fromball_buffer==0 and Input.is_action_pressed("break"):
		supertorpedo_auto = true
	
	if (((torpedo_right_input and torpedo_left_input) or (break_input and supertorpedo_fromball_buffer<=-20)) or supertorpedo_auto) and !plus and !minus:
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
			
	elif Input.is_action_just_pressed("up") and Input.is_action_just_pressed("down") and scooting==0:
			scooting=scoot_cooldown
			print("scootforward")
				
	else:
		supertorpedo_buffer=clamp(supertorpedo_buffer-1,0,supertorpedo_max_buffer)	
		supertorpedo_mode=-1
		supertorpedo_angle=0	
		supertorpedo_speed=clamp(supertorpedo_speed-supertorpedo_speed_deaccel,0.0,max_supertorpedo_speed)
	
	rotation.z+=supertorpedo_speed
	
	if torpedo_left_input and !torpedo_right_input: #TORPEDO INPUT PRESSED
		if torpedo_left==-1:
			torpedo_left=torpedo_max_buffer
			if !supertorpedo_buffer>0:
				torpedo_target=rotation.z+90
			#torpedo_target=torpedo_correction+90
		#else:
			#torpedo_left=-1
			
		if torpedo_left>0:
			torpedo_left-=1
			
		# START ADJUSTING ANGLE
		if !minus and !plus:
			rotation.z+=torpedo_speed
		elif Input.is_action_just_pressed("up") and scooting>=0:
			scooting=-scoot_cooldown
			print("scoot-1")
	else: #TORPEDO INPUT NOT PRESSED
		if torpedo_left>0 and !supertorpedo_buffer>0:
			# SKIP TO 90 DEGREE ANGLE
			#torpedo_correction=torpedo_target
			torpedo_snapping=torpedo_snapping_max
			#rotation.z=torpedo_target
		torpedo_left=-1
		
	if torpedo_right_input and !torpedo_left_input: #TORPEDO INPUT PRESSED
		if torpedo_right==-1:
			torpedo_right=torpedo_max_buffer
			if !supertorpedo_buffer>0:
				torpedo_target=rotation.z-90
			#torpedo_target=torpedo_correction+90
		#else:
			#torpedo_left=-1
			
		if torpedo_right>0:
			torpedo_right-=1
			
		# START ADJUSTING ANGLE
		if !minus and !plus:
			rotation.z-=torpedo_speed
		elif Input.is_action_just_pressed("down") and scooting<=0:
			scooting=scoot_cooldown
			print("scoot1")
			#...OR, IF GROUNDED, SCOOT	
	else: #TORPEDO INPUT NOT PRESSED
		if torpedo_right>0 and !supertorpedo_buffer>0:
			# SKIP TO 90 DEGREE ANGLE
			torpedo_snapping=torpedo_snapping_max
			#torpedo_correction=torpedo_target
			#rotation.z=torpedo_target
		torpedo_right=-1
	
	#endregion
	
	if torpedo_snapping>=0:
		torpedo_snapping-=1
		if !minus and !plus:
			rotation.z=lerp_angle(rotation.z,torpedo_target,0.2)
	#rotation.z += torpedo_correction_turbo/100
	

	fish_test_1.position = position
	fish_test_1.rotation = rotation

	if contactgrounded == true:
		groundtimer=coyotetime
		
	else:
		groundtimer=clamp(groundtimer-1,0,coyotetime)
		#if animation_player.current_animation == "idle":
		#	animation_player.play("fall")
	if groundtimer > 0: 
		grounded = true
		jump_weaken=1
		#gravity_scale=1
	else:
		grounded = false
		if jump_weaken>jump_weaken/jump_weaken_factor:
			jump_weaken/=jump_weaken_factor
		#gravity_scale=0.5
	
	if can_move:
		#movement(delta)
		movement_torque(delta)
		
	#dif level_finished:
	#	gravity_scale = move_toward(gravity_scale,0.0,finish_deceleration * delta)
	
	if level_finish_cooldown_tickstate != 0:
		#print("hello, goin down")
		level_finish_cooldown=clamp(level_finish_cooldown-1,0,level_finish_cooldown_max)
		if level_finish_cooldown == 0 and level_finish_cooldown_tickstate!=0:
			level_finish_cooldown_tickstate = 0
		
	"""if level_finish_cooldown == 0 and level_finished and can_move == false and am_finishtouching == true:
		var target_collided = finishcheckray.get_collider()
		var collided_area = target_collided.get_node("../FinishArea")
		global_position = collided_area.global_position + collided_area.gravity_point_center
		level_manager.latestcheckpoint = global_position"""
	var supvl = 1
	if supertorpedo_auto == true:
		supvl=supertorpedo_velimit
	linear_velocity.x = clamp(linear_velocity.x, -max_velocity*supvl, max_velocity*supvl)
	linear_velocity.z = clamp(linear_velocity.z, -max_velocity*supvl, max_velocity*supvl)
	#if linear_velocity.x > max_velocity*supertorpedo_velimit:
		#linear_velocity
	
	if Input.is_action_just_released("jump") or Input.is_action_just_released("counterjump"):
		if flapstate==0 or flapstate==-1:
			pass
		else:
			flapstate=-1
		
			
			#playback.travel("Flap")
			#animation_tree.set("parameters/Flap/TimeSeek/seek_request", 0.15)
			animation_tree.set("parameters/Flap/TimeScale/scale", 1.0)
			animation_tree.set("parameters/InvFlap/TimeScale/scale", 1.0)	
			
			jump()
			hogginground = hogginground_cooldownmax
		
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("counterjump")) and flapstate==0: # and level_finish_cooldown_tickstate!=-1:
		flapstate=1
		if Input.is_action_pressed("jump"):
			
			playback.travel("Flap")
			animation_tree.set("parameters/Flap/TimeSeek/seek_request", 0)
			animation_tree.set("parameters/Flap/TimeScale/scale", 3.0)
		else:
			playback.travel("InvFlap")
			animation_tree.set("parameters/InvFlap/TimeSeek/seek_request", 0)
			animation_tree.set("parameters/InvFlap/TimeScale/scale", 3.0)
		#animation_player.speed_scale = 1.5
		#animation_player.seek(0.166, true)

	if (scooting==scoot_cooldown or scooting==-scoot_cooldown):
		
		var scootdir = 0
		if (!torpedo_left_input or !torpedo_right_input):
			if scooting>0:
				scootdir=1
			else:
				scootdir=-1
			apply_central_impulse(basis.x  * scoot_power * scootdir)
		else:
			apply_central_impulse(basis.z  * scoot_power * -1)
	if scooting!=0:
		if scooting>0:
			scooting-=1
		else:
			scooting+=1
	if (minus or plus):
		if (torpedo_left_input and torpedo_right_input) or Input.is_action_pressed("break"):
			apply_central_impulse(-basis.z  * passive_scoot_power)
		elif torpedo_right_input:
			apply_central_impulse(basis.x  * passive_scoot_power)
		elif torpedo_left_input:
			apply_central_impulse(-basis.x  * passive_scoot_power)
			
	if supertorpedo_fromball_buffer <=0 and (supertorpedo_speed == max_supertorpedo_speed or supertorpedo_speed == -max_supertorpedo_speed):
		supertorpedo_auto = true
		
		print("drill ON")
	if supertorpedo_auto == true:
		if (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("break") or plus or minus):
			supertorpedo_auto=false
			supertorpedo_speed/=2
		#apply_central_force(-basis.z * supertorpedo_drill_speed)
		#gravity_scale = 0.25
		linear_damp = 0.1
		
	else:
		#gravity_scale=0.5
		if !plus and !minus:
			linear_damp = 0
		else: 
			linear_damp = 0#.5
func jump():
	
	var jump_direction = global_basis.y.normalized()
	var jump_redirect_percentage: float = 0.3
	var horizontal_vel = Vector3(linear_velocity.x, 0, linear_velocity.z)
	var horizontal_speed = horizontal_vel.length()
	var horizontal_dir = horizontal_vel.normalized()
	var alignment = jump_direction.dot(horizontal_dir)
	
	var redirection_factor = max(0.0, alignment)
	var momentum_boost = horizontal_speed * redirection_factor
	
	var final_jump_velocity = jump_direction * (jump_power + momentum_boost)
	
	apply_central_impulse(global_basis.y.normalized()*final_jump_velocity*jump_weaken)
	jump_weaken/=jump_weaken_factor
	
	'''
	if grounded and playback.get_current_node()=="Flap" and animation_player.current_animation_position>0.1:
		apply_central_impulse(global_basis.y  * jump_power )
		
		#THIS ISNT WORKING CURRENTLY
	else:
		
		apply_central_impulse(global_basis.y   * jump_power*jump_power_air_factor ) #vector3.up
	'''
	
func movement_torque(delta):
	var f_input = Input.get_action_raw_strength("forward") - Input.get_action_raw_strength("backward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	var t_input = Input.get_action_raw_strength("up") - Input.get_action_raw_strength("down")
	
	#var as_d_input = Input.get_action_raw_strength("ANGULAR speed down") - Input.get_action_raw_strength("ANGULAR speed up")
	#var ls_d_input = Input.get_action_raw_strength("LINEAR speed down") - Input.get_action_raw_strength("LINEAR speed up")
	
	var camera_transform = camera_3d.get_camera_transform()
	
	var relative_camera_direction_z = camera_transform.basis.z.normalized()
	var relative_camera_direction_x = camera_transform.basis.x.normalized()
	
	#var cam_forward = -camera_3d.global_transform.basis.z.normalized()
	
	var direction_f = f_input * relative_camera_direction_z
	var direction_h = h_input * relative_camera_direction_x
	

	var move_direction_f = (relative_camera_direction_z * f_input).normalized() #
	#var move_direction_h = (relative_camera_direction_x * h_input).normalized()
	
	move_direction_f.y = 0 # Keep force horizontal
	#if move_direction_h.length() > 0:
	local_x = global_transform.basis.x
	local_y = global_transform.basis.y
	local_z = global_transform.basis.z
	top = local_y * half_height
	bottom = -local_y * half_height	
	#if shape is ConvexPolygonShape3D:
	#	var points = shape.points  # full extents (x, y, z)
	#	var min_v = points[0]
	#	var max_v = points[0]
	#	for p in points:
	#		min_v = min_v.min(p)
	#		max_v = max_v.max(p)
	#	var size = max_v - min_v
	#	var extents = size * 0.5
	#	var half_length = extents.z
	#	var half_width = extents.x
	#	var half_height = extents.y
	
	#var force = f_input * torpedo_speed * 10 * local_z
	
	#apply_force(force, top)
	#apply_force(-200*local_z, bottom)
	#apply_force(force, top)
	#apply_force(-force, bottom)
	
	#spawn_marker(top)
	#local_x, local_z, local_y
	if !supertorpedo_auto:
		apply_torque(f_input * local_x.normalized() * pageturn_speed)
		#apply_torque(t_input * local_z.normalized() * torpedoturn_speed)
		apply_torque(h_input * local_y.normalized() * boomerangturn_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Flap":
		print("finished_flapping_finished_flapping_finished_flapping_finished_flapping")
		animation_tree.set("parameters/Flap/TimeSeek/seek_request", 0.5) # Jump to 0.5s, update the sprite immediately
		animation_tree.set("parameters/Flap/TimeScale/scale", 0.0) # Stop at the current position (don't reset to beginning)
