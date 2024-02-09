extends CharacterBody3D

var speed : float

@export_group("Movement")
@export var walk_speed : float = 4.5
@export var walk_speed_when_jumping : float = 2.0
@export var sprint_speed : float = 7.0
@export var sprint_speed_when_jumping : float = 5.0
@export var jump_speed : float = 4.5

@export var acceleration : float = 15.0
@export var deceleration : float = 10.0

@export var look_sensitivity : float = 3.5

var head_bob_frequency : float
var head_bob_amplitude : float

@export_group("Head Bob")
@export var head_bob_enabled : bool = false
@export var stationary_head_bob_frequency : float = 3.0
@export var stationary_head_bob_amplitude : float = 0.015
@export var walk_head_bob_frequency : float = 15.0
@export var walk_head_bob_amplitude : float = 0.05
@export var sprint_head_bob_frequency : float = 20.0
@export var sprint_head_bob_amplitude : float = 0.1

var head_bob_timer : float = 0.0

var moving : bool = false
var sprinting : bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera : Node3D = $Camera

func _input(event : InputEvent):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.001 * look_sensitivity)
		camera.rotate_x(-event.relative.y * 0.001 * look_sensitivity)

func _physics_process(delta : float):
	if Input.is_action_pressed("Sprint"):
		if not is_on_floor():
			velocity.y -= gravity * delta
			speed = sprint_speed_when_jumping
		else:
			speed = sprint_speed
		sprinting = true
	else:
		if not is_on_floor():
			velocity.y -= gravity * delta
			speed = walk_speed_when_jumping
		else:
			speed = walk_speed
		sprinting = false
	
	print(speed)
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_speed
	
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		moving = true
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		moving = false
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	
	if head_bob_enabled && is_on_floor():
		if moving:
			if sprinting:
				#head_bob_frequency = lerp(head_bob_frequency, sprint_head_bob_frequency, 5.0 * delta)
				head_bob_frequency = sprint_head_bob_frequency
				head_bob_amplitude = lerp(head_bob_amplitude, sprint_head_bob_amplitude, 10.0 * delta)
			else:
				#head_bob_frequency = lerp(head_bob_frequency, walk_head_bob_frequency, 5.0 * delta)
				head_bob_frequency = walk_head_bob_frequency
				head_bob_amplitude = lerp(head_bob_amplitude, walk_head_bob_amplitude, 10.0 * delta)
		else:
			#head_bob_frequency = lerp(head_bob_frequency, stationary_head_bob_frequency, 5.0 * delta)
			head_bob_frequency = stationary_head_bob_frequency
			head_bob_amplitude = lerp(head_bob_amplitude, stationary_head_bob_amplitude, 10.0 * delta)
		head_bob_timer += delta
		camera.position.y = 1.35 + sin(head_bob_timer * head_bob_frequency) * head_bob_amplitude
		print("head_bob_frequency > ", head_bob_frequency)
		print("head_bob_amplitude > ", head_bob_amplitude)
	
	move_and_slide()

#func _process(delta : float):

