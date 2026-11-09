extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 2.0

# Referencia a la cámara dentro de tu estructura
@onready var camera_3d: Camera3D = $cameraPoint/Camera3D

func _ready() -> void:
	if camera_3d:
		camera_3d.make_current()

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Manejar salto (opcional, por si quieres mantenerlo)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Movimiento independiente (WASD / Flechas) alineado a la vista de la cámara
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var cam_forward = camera_3d.global_basis.z
	var cam_right = camera_3d.global_basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()
	
	var direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Aplicar el movimiento físico
	move_and_slide()

	# 4. Sistema de Apuntado al Cursor del Mouse (Aim-to-Cursor) con sensibilidad
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera_3d.project_ray_origin(mouse_pos)
	var normal = camera_3d.project_ray_normal(mouse_pos)

	# Creamos un plano horizontal invisible a la altura del personaje para intersectar el rayo del mouse
	var floor_plane = Plane(Vector3.UP, global_position.y)
	var intersection = floor_plane.intersects_ray(origin, normal)
	
	if intersection:
		# Calculamos el punto de mira manteniendo la misma altura Y para que no se incline
		var look_target = Vector3(intersection.x, global_position.y, intersection.z)
		
		# Evitamos errores si el mouse está justo encima del centro del personaje
		if global_position.distance_to(look_target) > 0.1:
			# 1. Calculamos la rotación exacta hacia la que debe mirar el personaje
			var target_transform = global_transform.looking_at(look_target, Vector3.UP)
			
			# 2. Suavizamos la rotación actual hacia la rotación objetivo usando lerp
			global_transform.basis = global_transform.basis.slerp(target_transform.basis, ROTATION_SPEED * delta)
