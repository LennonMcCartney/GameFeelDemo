extends Node3D

@export var jump_particles : PackedScene

func _ready():
	GameManager.jump.connect(spawn_jump_particles)

func spawn_jump_particles(spawn_position : Vector3):
	var jump_particles_instance : GPUParticles3D = jump_particles.instantiate()
	jump_particles_instance.emitting = true
	add_child(jump_particles_instance)
	jump_particles_instance.global_position = spawn_position
