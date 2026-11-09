@tool
extends MeshInstance3D

# Tamaño de cada cuadro en píxeles dentro de la textura generada
@export var square_size: int = 8

func _ready() -> void:
	# 1. Crear una imagen base de 64x64 píxeles
	var img = Image.create(64, 64, false, Image.FORMAT_RGB8)
	
	# 2. Dibujar el patrón de cuadros (Blanco y Gris Oscuro)
	for x in range(64):
		for y in range(64):
			var is_white = ((x / square_size) + (y / square_size)) % 2 == 0
			img.set_pixel(x, y, Color(0.8, 0.8, 0.8) if is_white else Color(0.2, 0.2, 0.2))
	
	# 3. Convertir la imagen en textura
	var texture = ImageTexture.create_from_image(img)
	
	# 4. Crear el material y aplicarle la textura con repetición (UV Scale)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.uv1_scale = Vector3(20, 20, 20) # Ajusta este valor para hacer los cuadros más grandes o pequeños en el mapa
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	
	# 5. Asignar el material al mesh
	set_surface_override_material(0, mat)
