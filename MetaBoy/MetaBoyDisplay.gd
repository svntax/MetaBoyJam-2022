extends Control

signal metaboy_selected(attributes)

onready var part_back = $MainBody/Back
onready var part_body = $MainBody/Body
onready var part_body_02 = $MainBody/Body2
onready var part_face = $MainBody/Face
onready var part_hat = $MainBody/Hat
onready var part_neck = $MainBody/Neck
onready var part_waist = $MainBody/Waist
onready var part_weapon = $MainBody/Weapon

onready var animation_player = $AnimationPlayer
onready var name_label = $Name
onready var button = $Button

var metaboy_attributes = { # Default to developer's MetaBoy
	"Body": "Superhero",
	"Face": "Loud-Crying",
	"Weapon": "Yatagan",
}

func _ready():
	animation_player.play("run", -1, 2)

func select() -> void:
	button.grab_focus()

func set_metaboy_name(metaboy_name: String) -> void:
	name_label.text = metaboy_name

func set_metaboy_attributes(attributes: Dictionary, collection: int = MetaBoyGlobals.Collection.OG) -> void:
	metaboy_attributes = attributes
	var path_root = ""
	if collection == MetaBoyGlobals.Collection.OG:
		path_root = "res://MetaBoy/spritesheets/"
	elif collection == MetaBoyGlobals.Collection.STX:
		path_root = "res://MetaBoy/spritesheets_stx/"
	var show_back = false
	var show_hat = false
	var show_neck = false
	var show_waist = false
	for key in attributes.keys():
		var value = attributes.get(key)
		var path = path_root + str(key) + "/" + str(value).replace(" ", "-") + ".png"
		if ResourceLoader.exists(path):
			if key == "Back":
				part_back.texture = load(path)
				show_back = true
			elif key == "Body":
				part_body.texture = load(path)
				# For the STX collection, Monster Suit has the teeth as an additional layer
				if collection == MetaBoyGlobals.Collection.STX and \
						(value.replace(" ", "-") == "Monster-Suit"):
					var path_teeth = path_root + "/Teeth/Monster-Suit-Teeth.png"
					part_body_02.texture = load(path_teeth)
			elif key == "Face":
				part_face.texture = load(path)
			elif key == "Hat":
				part_hat.texture = load(path)
				show_hat = true
			elif key == "Neck":
				part_neck.texture = load(path)
				show_neck = true
			elif key == "Waist":
				part_waist.texture = load(path)
				show_waist = true
			elif key == "Weapon":
				part_weapon.texture = load(path)
	
	metaboy_attributes["Collection"] = collection
	
	part_back.visible = show_back
	part_hat.visible = show_hat
	part_neck.visible = show_neck
	part_waist.visible = show_waist
	
	# Check for key in case of mismints that are missing these attributes
	if attributes.has("Body") and attributes.has("Face"):
		var body_type = attributes.get("Body").replace(" ", "-")
		# Bodies with dark screens need the light version of the face
		if MetaBoyGlobals.is_dark_screen_body(body_type, collection):
			var face_type = attributes.get("Face").replace(" ", "-")
			var face_light_version_texture = MetaBoyGlobals.get_face_light_version(face_type, collection)
			if face_light_version_texture:
				part_face.texture = face_light_version_texture

func _on_Button_pressed():
	emit_signal("metaboy_selected", metaboy_attributes)
