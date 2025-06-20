@tool
extends Node2D

# --- PROTOCOLLO FORGIATORE VISIVO v2.1 "AUTOMATIZZATO" ---
@export_group("Arsenale dell'Architetto")
@export var blueprint_file: String = "res://data/blueprints/laboratorio_layout.json"

@export var forge_from_blueprint: bool = false:
	set(value):
		if value:
			print("--- VULCANO: FORGIATURA DA BLUEPRINT ATTIVATA ---")
			_forge_scene()

# Il pulsante di estrazione è stato rimosso. L'automazione è gestita dal plugin.

func _ready():
	pass

# --- API PUBBLICA PER IL PLUGIN ---
func extract_scene_data():
	if not Engine.is_editor_hint(): return

	var background = get_node_or_null("Background")
	var automa = get_node_or_null("Automa")
	if not background or not automa: return

	var file_read = FileAccess.open(blueprint_file, FileAccess.READ)
	var data = JSON.parse_string(file_read.get_as_text())
	file_read.close()
	if data == null: return

	data["background"]["scale"]["x"] = background.scale.x
	data["background"]["scale"]["y"] = background.scale.y
	
	data["automa"]["position"]["x"] = automa.position.x
	data["automa"]["position"]["y"] = automa.position.y
	data["automa"]["scale"]["x"] = automa.scale.x
	data["automa"]["scale"]["y"] = automa.scale.y

	var file_write = FileAccess.open(blueprint_file, FileAccess.WRITE)
	file_write.store_string(JSON.stringify(data, "\t"))
	file_write.close()
	
	print("--- VULCANO: Sinergia estratta e blueprint aggiornato (chiamata da Sovrintendente). ---")


func _forge_scene():
	# ... la logica di forgiatura rimane identica ...
	if not Engine.is_editor_hint(): return
	var background = get_node_or_null("Background")
	var automa = get_node_or_null("Automa")
	var hotspot_container = get_node_or_null("HotspotAutoma")
	if not background or not automa or not hotspot_container: return
	for n in hotspot_container.get_children():
		hotspot_container.remove_child(n)
		n.queue_free()
	if not FileAccess.file_exists(blueprint_file): return
	var file = FileAccess.open(blueprint_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null: return
	background.texture = load(data["background"]["texture"])
	background.size = background.texture.get_size()
	background.scale = Vector2(data["background"]["scale"]["x"], data["background"]["scale"]["y"])
	automa.texture = load(data["automa"]["texture"])
	automa.position = Vector2(data["automa"]["position"]["x"], data["automa"]["position"]["y"])
	automa.scale = Vector2(data["automa"]["scale"]["x"], data["automa"]["scale"]["y"])
	if data.has("hotspots"):
		var hotspot_scene = load("res://scenes/components/interactables/Hotspot.tscn")
		for hotspot_data in data["hotspots"]:
			var new_hotspot = hotspot_scene.instantiate()
			new_hotspot.name = hotspot_data["name"]
			new_hotspot.position = Vector2(hotspot_data["position"]["x"], hotspot_data["position"]["y"])
			hotspot_container.add_child(new_hotspot)
	print("--- FORGIATURA COMPLETATA ---")
