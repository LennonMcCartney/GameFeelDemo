extends Node3D

@onready var jump_particles_packed_scene : PackedScene = preload("res://Scenes/Particles/JumpParticles.tscn")
var jump_particles : GPUParticles3D

func _ready():
	jump_particles = jump_particles_packed_scene.instantiate()
	add_child(jump_particles)
	
	GameManager.jump.connect(spawn_jump_particles)

func spawn_jump_particles(spawn_position : Vector3):
	#var jump_particles_instance : GPUParticles3D = jump_particles.instantiate()
	jump_particles.global_position = spawn_position
	jump_particles.emitting = true
	#add_child(jump_particles_instance)
