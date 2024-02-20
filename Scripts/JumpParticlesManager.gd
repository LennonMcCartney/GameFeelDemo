extends GPUParticles3D

func _ready():
	GameManager.jump.connect(spawn_jump_particles)

func spawn_jump_particles(spawn_position : Vector3):
	global_position = spawn_position
	emitting = true
