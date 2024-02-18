extends Node3D

@onready var sprint_particles_packed_scene : PackedScene = preload("res://Scenes/Particles/SprintParticles.tscn")
var sprint_particles : GPUParticles3D

func _ready():
	sprint_particles = sprint_particles_packed_scene.instantiate()
	add_child(sprint_particles)
	
	GameManager.sprint.connect(spawn_sprint_particles)

func spawn_sprint_particles(spawn_position : Vector3, speed : float):
	sprint_particles.global_position = spawn_position
	sprint_particles.emitting = true
