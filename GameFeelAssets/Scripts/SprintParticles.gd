extends GPUParticles3D

func _ready():
	GameManager.sprint.connect(spawn_sprint_particles)

func spawn_sprint_particles(spawn_position : Vector3):
	global_position = spawn_position
	emitting = true
