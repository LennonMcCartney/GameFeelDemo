extends CharacterBody3D

@export_category("Movement")
@export var auto_sprint : bool = false

@export var blink : bool = false

@export_group("Speed")
var speed : float
@export var walk_speed : float = 3.0
@export var walk_speed_when_jumping : float = 2.0
@export var sprint_speed : float = 7.5
@export var sprint_speed_when_jumping : float = 5.0

@export_group("Jump")
@export var jump_height : float = 1.0
@export var jump_time_to_ascend : float = 1.0
@export var jump_time_to_descend : float = 1.0

var jump_counter : int = 0

@onready var jump_speed : float = (2.0 * jump_height) / jump_time_to_ascend
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_ascend * jump_time_to_ascend)
@onready var fall_gravity : float = (2.0 * jump_height) / (jump_time_to_descend * jump_time_to_descend)

@onready var double_jump_speed : float

@export_group("Acceleration")
@export var acceleration : float = 15.0
@export var deceleration : float = 10.0

@export_category("Input")
@export_group("Look Sensitivity")
var look_sensitivity : float
@export var mouse_sensitivity : float = 0.5
@export var controller_sensitivity : float = 1.5

@export var angular_acceleration : float = 15.0

@export var vertical_max_look_angle : float = 1.0
@export var vertical_min_look_angle : float = 1.0

var aim_input : Vector2 = Vector2()

@export_category("Particles")
@export_group("Sprint Particles")
@export var sprint_particles_enabled : bool = false

@onready var camera_pivot_horizontal : Node3D = $CameraPivotHorizontal
@onready var camera_pivot_vertical : Node3D = $CameraPivotHorizontal/CameraPivotVertical
@onready var camera : Camera3D = $CameraPivotHorizontal/CameraPivotVertical/SpringArm/Camera

@onready var sophia_skin : SophiaSkin = $SophiaSkin

@onready var jump_particle_ray_cast : RayCast3D = $JumpParticleRayCast

@onready var jump_audio_player : AudioStreamPlayer3D = $AudioPlayers/JumpAudioPlayer
@onready var double_jump_audio_player : AudioStreamPlayer3D = $AudioPlayers/DoubleJumpAudioPlayer
@onready var footsteps_audio_player : AudioStreamPlayer3D = $AudioPlayers/FootstepsAudioPlayer

var direction : Vector3

func _ready():
	sophia_skin.blink = blink

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		aim_input = event.relative

func _process(delta):
	var controller_aim_input : Vector2 = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
	if controller_aim_input != Vector2():
		aim_input = controller_aim_input
		look_sensitivity = controller_sensitivity
	else:
		look_sensitivity = mouse_sensitivity
	
	camera_pivot_horizontal.rotate_y(-aim_input.x * delta * look_sensitivity)
	camera_pivot_vertical.rotate_x(-aim_input.y * delta * look_sensitivity)
	camera_pivot_vertical.rotation.x = clampf(camera_pivot_vertical.rotation.x, deg_to_rad(vertical_min_look_angle), deg_to_rad(vertical_max_look_angle))
	aim_input = Vector2()
	
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	direction = (camera_pivot_horizontal.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		sophia_skin.global_rotation.y = lerp_angle(sophia_skin.global_rotation.y, atan2(-direction.x, -direction.z), angular_acceleration * delta)

func _physics_process(delta : float):
	if get_sprinting():
		if not is_on_floor():
			velocity.y -= get_gravity() * delta
			speed = sprint_speed_when_jumping
		else:
			speed = sprint_speed
	else:
		if not is_on_floor():
			velocity.y -= get_gravity() * delta
			speed = walk_speed_when_jumping
		else:
			speed = walk_speed
	
	if get_jump():
		velocity.y = jump_speed
	elif is_on_floor():
		jump_counter = 0
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		if is_on_floor():
			if !footsteps_audio_player.playing:
				footsteps_audio_player.play()
			sophia_skin.move()
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
		footsteps_audio_player.stop()
		sophia_skin.idle()
	
	if not is_on_floor():
		footsteps_audio_player.stop()
		if velocity.y < 0.0:
			sophia_skin.fall()
		else:
			sophia_skin.jump()
	elif sprint_particles_enabled:
			var horizontal_velocity : Vector2 = Vector2(velocity.x, velocity.z)
			GameManager.sprint.emit(global_position + Vector3(0.0, 0.15, 0.0), horizontal_velocity.length())
	
	move_and_slide()

func get_gravity() -> float:
	if velocity.y < 0.0:
		return fall_gravity
	else:
		return jump_gravity

func get_sprinting() -> float:
	return auto_sprint or Input.is_action_pressed("Sprint")

func get_jump() -> bool:
	if is_on_floor():
		if Input.is_action_pressed("Jump"):
			jump_counter = 1
			if jump_particle_ray_cast.is_colliding():
				GameManager.jump.emit(jump_particle_ray_cast.get_collision_point())
			jump_audio_player.play()
			return true
	else:
		if Input.is_action_just_pressed("Jump"):
			if jump_counter <= 1:
				jump_counter += 1
				double_jump_audio_player.play()
				return true
	return false
