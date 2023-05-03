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
	collection = metadata.get("Collection", Collection.OG)
	back = metadata.get("Back", "")
	body = metadata.get("Body", "")
	face = metadata.get("Face", "")
	hat = metadata.get("Hat", "")
	neck = metadata.get("Neck", "")
	weapon = metadata.get("Weapon", "")
	waist = metadata.get("Waist", "")
	background = metadata.get("Background", "")
	id = metadata.get("ID", -1)

func set_id(new_id: int):
	id = new_id

func get_collection_by_name() -> String:
	return Collection.keys()[collection]
