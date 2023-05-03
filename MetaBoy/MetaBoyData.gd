extends Reference
class_name MetaBoyData

# A class that represents a MetaBoy character.

enum Collection { OG, STX }

var collection : int setget set_collection
var back : String
var body : String
var face : String
var hat : String
var neck : String
var weapon : String
var waist : String
var background : String
var id : int setget set_id

func _init(metadata: Dictionary = {}):
	set_metadata(metadata)

func set_collection(new_collection: int) -> void:
	if new_collection in Collection.values():
		collection = new_collection

func set_metadata(metadata: Dictionary) -> void:
	for attribute in metadata.keys():
		if attribute == "Collection":
			collection = metadata.get("Collection", Collection.OG)
		elif attribute == "Back":
			back = metadata.get("Back", "")
		elif attribute == "Body":
			body = metadata.get("Body", "")
		elif attribute == "Face":
			face = metadata.get("Face", "")
		elif attribute == "Hat":
			hat = metadata.get("Hat", "")
		elif attribute == "Neck":
			neck = metadata.get("Neck", "")
		elif attribute == "Weapon":
			weapon = metadata.get("Weapon", "")
		elif attribute == "Waist":
			waist = metadata.get("Waist", "")
		elif attribute == "Background":
			background = metadata.get("Background", "")
		elif attribute == "ID":
			id = metadata.get("ID", -1)

func set_id(new_id: int):
	id = new_id

func get_collection_by_name() -> String:
	return Collection.keys()[collection]

func get_attributes_as_dictionary() -> Dictionary:
	return {
		"Back": back,
		"Body": body,
		"Face": face,
		"Hat": hat,
		"Neck": neck,
		"Weapon": weapon,
		"Waist": waist,
		"Background": background,
		"Collection": collection,
	}
