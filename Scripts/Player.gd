extends CharacterBody3D

@export_group("Speed")
var speed : float
@export var walk_speed : float = 3.0
@export var walk_speed_when_jumping : float = 2.0
@export var sprint_speed : float = 7.5
@export var sprint_speed_when_jumping : float = 5.0

@export_group("Jump")
@export var jump_height : float = 1.0
@export var time_to_ascend : float = 1.0
@export var time_to_descend : float = 1.0

@onready var jump_speed : float = (2.0 * jump_height) / time_to_ascend
@onready var jump_gravity : float = (2.0 * jump_height) / (time_to_ascend * time_to_ascend)
@onready var fall_gravity : float = (2.0 * jump_height) / (time_to_descend * time_to_descend)

@export_group("Acceleration")
@export var acceleration : float = 15.0
@export var deceleration : float = 10.0

@export_group("Look Sensitivity")
var look_sensitivity : float
@export var mouse_sensitivity : float = 0.5
@export var controller_sensitivity : float = 1.5

var aim_input : Vector2 = Vector2()

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_pivot : Node3D = $CameraPivot
@onready var camera : Camera3D = $CameraPivot/SpringArm3D/Camera

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
	
	rotate_y(-aim_input.x * delta * look_sensitivity)
	camera_pivot.rotate_x(-aim_input.y * delta * look_sensitivity)
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-70.0), deg_to_rad(15.0))
	aim_input = Vector2()

func _physics_process(delta : float):
	if Input.is_action_pressed("Sprint"):
		if not is_on_floor():
			#print("not is_on_floor()")
			velocity.y -= get_gravity() * delta
			speed = sprint_speed_when_jumping
		else:
			#print("is_on_floor()")
			speed = sprint_speed
	else:
		if not is_on_floor():
			#print("not is_on_floor()")
			velocity.y -= get_gravity() * delta
			speed = walk_speed_when_jumping
		else:
			#print("is_on_floor()")
			speed = walk_speed
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_speed
	
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	
	move_and_slide()

func get_gravity() -> float:
	if velocity.y < 0.0:
		return fall_gravity
	else:
		return jump_gravity
