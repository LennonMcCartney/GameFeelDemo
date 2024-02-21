extends GPUParticles3D

#@onready var sprint_particles_packed_scene : PackedScene = preload("res://Scenes/Particles/SprintParticles.tscn")
#var sprint_particles : GPUParticles3D

func _ready():
	#sprint_particles = sprint_particles_packed_scene.instantiate()
	#add_child(sprint_particles)
	GameManager.sprint.connect(spawn_sprint_particles)

func spawn_sprint_particles(spawn_position : Vector3, speed : float):
	global_position = spawn_position
	if speed > 8.0:
		#print("emitting speed > ", speed)
		emitting = true
	else:
		#print("not emitting speed > ", speed)
		emitting = false