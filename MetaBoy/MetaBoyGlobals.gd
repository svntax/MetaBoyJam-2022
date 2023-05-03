extends Node

# Address for the original MetaBoy collection smart contract
const CONTRACT_OG = "0x1D006a27BD82E10F9194D30158d91201E9930420"
# Address for the STX MetaBoy collection
const CONTRACT_STX = "SP2W12MNM4SPV37VZHN4GCDG35G9ACG3FDKK7WF04"
# For storing the responses of NFT metadata
var user_nfts_loopring : Array = []
var user_nfts_stacks : Array = []

enum Collection { OG, STX }

# All attribute types for the OG MetaBoy collection
const BACK_TYPES = ["Angel-Wings", "Demon-Wings", "Fireball", "Golden-Wings", "Sai-Backpack", "Sword-Backpack"]
const BODY_TYPES = ["Angel", "Assassin", "Astronaut", "Biker", "Bloodied", "Bread-Slice", "Camouflage", "Country", "Cowboy", "Demon", "Explorer", "Galaxy", "Gentleman", "Goth-Girl", "Lifeguard", "Light-Blue", "Lizard", "Lumberjack", "Mom-Jeans", "Monk", "Monster-Suit", "Muscular-Warrior", "Neon-Solid", "Neon-Transparent", "Nobleman", "Open-Jacket", "Prisoner", "Red-Dress", "Roman-Gladiator", "Samurai", "Santa-Claus", "Schoolboy", "Schoolgirl", "Stealth", "Stone", "Stripped", "Suit", "Superhero", "Supervillain", "Survivor", "Suspenders", "Tiger", "Turtle", "Underwater-Suit", "Water", "Watermelon", "Wood", "Yellow-Overalls", "Yellow", "Zombie"]
const FACE_TYPES = ["404-Face", "6_6", "Angel-Smile", "Angry", "Bearded-Cowboy", "Big-Chin", "Big-Moustashe", "Big-Teeth", "Bubblegum", "Cat", "Confused", "Crazy", "Crying", "Cyclops", "Demon", "Dog", "Double-Chin", "Dumb-Laugh", "Empty-Face", "Female-Villian", "Furious-Face", "Galaxy", "Glasses", "Goatee", "Got-You", "Grinding-Teeth", "Handsome-Face", "Happy-Clown", "Happy-Face", "Happy-Girl", "Hitman-Face", "Holding-a-Laugh", "Huge-Smile", "Loud-Crying", "Monocle", "Monster", "Mustashe-Hipster", "Neon-Face", "OoO", "Pig", "Rosy-Cheeks", "Sad-Zombie", "Sad", "Scary-Clown", "Seducing", "Serious", "Skull", "Smiling-Skull", "Smiling-Zombie", "Snobby-Kid", "Super-Angry", "Suprised", "Sweet", "Teeth-Smile", "Tongue-out", "Unibrow-Bandit", "Viper", "Whatever"]
const HAT_TYPES = ["Arrow-Through-Head", "Astronaut-Helmet", "Axe-Hat", "Bear-Hat", "Beret-Hat", "Bitcoin-Hat", "Bunny-Ears", "Cat-Ears", "Chefs-Hat", "Cowboy-Hat", "Crown", "Dark Purple Wizard Hat", "Dark-Hoodie", "Detective-Hat", "Ethereum-Hat", "Fedora", "Green-Headphones", "Green-Mowhawk", "Halo", "Hat-Blue", "Hat-Orange", "Jester-Hat", "Leafs", "Lion-Hat", "Medic-Hat", "Pirate-Hat", "Plague-Doctor-Mask", "Plague-Doctor-Hat", "Purple Wizard Hat", "Purple-Mowhawk", "Red-Mowhawk", "Ribbon", "Russian-Hat", "Samurai-Helmet", "Sea-Captain-Hat", "Skull-Top-Hat", "Steampunk-Hat", "Underwater-Helmet", "Viking-Helmet", "Warrior-Helmet", "Winged-Helmet", "Wizard-Hat", "Xmas-Hat", "Yellow Hat"]
const NECK_TYPES = ["Arrow-Quiver", "Binoculars", "Black-Scarf", "Blue-Bandana", "Dog-Tags", "Fur-Cape", "Medallion-Necklace", "Red-Bandana", "Red-Cape", "Red-Scarf", "Shoulder-Pads", "Skull-Bandana", "Teeth-Necklace"]
const WAIST_TYPES = ["Belt-empty-Holsters", "Belt-with-Both-Pistols", "Belt-with-Left-Pistol", "Belt-with-Right-Pistol", "Chain-Belt", "Champion-Belt", "Fighter-Belt", "Grenade-Belt", "Potion-Belt", "Satchel", "Warrior-Belt"]
const WEAPON_TYPES = ["Axe-and-Shield", "Bazooka", "Blade", "Bomb", "Bow-and-Arrow", "Bow", "Boxing-Gloves", "Chainsaw", "Cowboy-Both-Pistols", "Cowboy-Left-Pistol", "Cowboy-Right-Pistol", "Crowbar", "Daggers", "Dark-Staff", "Dynamite-Stick", "Elder-Wand", "Energy-Sword", "Flamethrower", "Golden-Blades", "Golden-Sword", "Gravity-Gun", "Harpoon", "Hook", "Katana", "Kunai", "Laser-Guns", "Lightning", "Love", "Medusa_s-Head", "Neon-Solid", "Neon-Transparent", "Retro-Futuristic-Rifle", "Robot-Claw", "Sai", "Side-Gun", "Slingshot", "Snail-Shell", "Sniper", "Spear-and-Shield", "Trident", "Wooden-Staff", "Wrist-Straps", "Yatagan", "Zombie-Hands"]

# All attribute types for the STX MetaBoy collection
const STX_BACK_TYPES = ["Angel-Wings","Arrow-Quiver", "BTC-Wings", "Demon-Wings", "Fireball", "Golden-Wings", "Sai-Backpack", "STX-Wings", "Sword-Backpack"]
const STX_BODY_TYPES = ["Angel", "Ape", "Assassin", "Astronaut", "Biker", "Bloodied", "Bread-Slice", "BTC-Body", "Camouflage", "Country", "Cowboy", "Demon", "Explorer", "Galaxy", "Gentleman", "Goth-Girl", "Lifeguard", "Light-Blue", "Lizard", "Lumberjack", "Mom-Jeans", "Monk", "Monster-Suit", "Muscular-Warrior", "Neon-Solid", "Neon-Transparent", "Nobleman", "Open-Jacket", "Prisoner", "Red-Dress", "Roman-Gladiator", "Samurai", "Schoolboy", "Schoolgirl", "Stealth", "Stone", "Stripped", "STX-Body", "Suit", "Superhero", "Supervillain", "Survivor", "Suspenders", "Tiger", "Turtle", "Underwater", "Water", "Watermelon", "Wood", "Yellow-Overalls", "Yellow", "Zombie"]
const STX_FACE_TYPES = ["404-Face", "6_6", "Angel-Smile", "Angry", "Ape-Face", "Bearded-Cowboy", "Big-Chin", "Big-Moustashe", "Big-Teeth", "Bubblegum", "Cat", "Confused", "Crazy", "Crying", "Cyclops", "Demon", "Devious-Face", "Dog", "Double-Chin", "Dumb-Laugh", "Empty-Face", "Female-Villian", "Furious-Face", "Galaxy", "Glasses", "Goatee", "Got-You", "Grinding-Teeth", "Handsome-Face", "Happy-Clown", "Happy-Face", "Happy-Girl", "Hitman-Face", "Holding-a-Laugh", "Huge-Smile", "Laser-Eyes", "Laser-Shooting-Eyes", "Loud-Crying", "Menacing-Face", "Monocle", "Monster", "Mustashe-Hipster", "Neon-Face", "OoO", "Plague-Doctor-Mask", "Pig", "Rosy-Cheeks", "Sad-Zombie", "Sad", "Scary-Clown", "Seducing", "Serious", "Skull", "Smiling-Skull", "Smiling-Zombie", "Snobby-Kid", "Super-Angry", "Suprised", "Sweet", "Teeth-Smile", "Tongue-Out", "Unibrow-Bandit", "Viper", "Whatever"]
const STX_HAT_TYPES = ["Arrow-Through-Head", "Astronaut-Helmet", "Axe-Hat", "Banana-Hat", "Bear-Hat", "BTC-Hair", "BTC-Hat", "Bunny-Ears", "Cat-Ears", "Chefs-Hat", "Conical-Hat", "Cowboy-Hat", "Crown", "Dark-Purple-Wizard-Hat", "Dark-Hoodie", "Detective-Hat", "Fedora", "Green-Beret-Hat", "Green-Headphones", "Green-Mowhawk", "Halo", "Hat-Blue", "Hat-Orange", "Jester-Hat", "Leafs", "Lion-Hat", "Medic-Hat", "Pirate-Hat", "Plague-Doctor-Hat", "Purple-Wizard-Hat", "Purple-Mowhawk", "Red-Beret-Hat", "Red-Mowhawk", "Ribbon", "Russian-Hat", "Samurai-Helmet", "Sea-Captain-Hat", "Skull-Top-Hat", "Steampunk-Hat", "STX-Hat", "STX-Headband", "Underwater-Helmet", "Viking-Helmet", "Warrior-Helmet", "Winged-Helmet", "Wizard-Hat", "Yellow Hat"]
const STX_NECK_TYPES = ["Black-Cape", "Black-Scarf", "Blue-Bandana", "BTC-Scarf", "Dog-Tags", "Fur-Cape", "Golden-Scarf", "Medallion-Necklace", "Red-Bandana", "Red-Cape", "Red-Scarf", "Shoulder-Pads", "Skull-Bandana", "STX-Scarf", "Superhero-Cape", "Teeth-Necklace"]
const STX_WAIST_TYPES = ["Belt-empty-Holsters", "Belt-with-Both-Pistols", "Belt-with-Left-Pistol", "Belt-with-Right-Pistol", "BTC-Belt", "Chain-Belt", "Champion-Belt", "Fighter-Belt", "Grenade-Belt", "Potion-Belt", "Satchel", "STX-Belt", "Warrior-Belt"]
const STX_WEAPON_TYPES = ["Axe-and-Shield", "Banana", "Bazooka", "Blade", "Blue-Boxing-Gloves", "Bomb", "Bow-and-Arrow", "Bow", "BTC-Blade", "Chainsaw", "Cowboy-Both-Pistols", "Cowboy-Left-Pistol", "Cowboy-Right-Pistol", "Crowbar", "Daggers", "Dark-Staff", "Dynamite-Stick", "Elder-Wand", "Energy-Sword", "Flamethrower", "Golden-Blades", "Golden-Sword", "Gravity-Gun", "Harpoon", "Hook", "Katana", "Kunai", "Laser-Guns", "Lightning", "Medusas-Head", "Neon-Solid", "Neon-Transparent", "Red-Boxing-Gloves", "Retro-Futuristic-Rifle", "Robot-Claw", "Sai", "Side-Gun", "Slingshot", "Snail-Shell", "Sniper", "Spear-and-Shield", "STX-Blaster", "Surrender-Flag", "Trident", "Wooden-Staff", "Wrist-Straps", "Yatagan", "Zombie-Hands"]

# These body attributes need the light version of a face if applicable.

# OG Collection
const DARK_SCREEN_BODIES = ["Bloodied", "Bread-Slice", "Camouflage", "Demon",
"Galaxy", "Goth-Girl", "Lizard", "Monk", "Muscular-Warrior", "Neon-Solid", 
"Open-Jacket", "Red-Dress", "Stone", "Supervillain", "Survivor", "Suspenders",
"Tiger", "Turtle", "Water", "Watermelon", "Wood", "Yellow", "Zombie"]

# STX Collection
const DARK_SCREEN_STX_BODIES = ["Ape", "Superhero",
"Bloodied", "Bread-Slice", "Camouflage", "Demon",
"Galaxy", "Lizard", "Monk", "Muscular-Warrior", "Neon-Solid", 
"Open-Jacket", "Red-Dress", "Stone", "Supervillain", "Survivor", "Suspenders",
"Tiger", "Turtle", "Water", "Watermelon", "Wood", "Yellow", "Zombie"]

var default_metaboy = MetaBoyData.new({
	"Body": "Superhero",
	"Face": "Loud-Crying",
	"Weapon": "Yatagan",
	"Collection": MetaBoyData.Collection.OG
})
# The MetaBoy the user has selected.
var selected_metaboy = MetaBoyData.new() setget set_selected_metaboy, get_selected_metaboy

func set_selected_metaboy(metaboy: MetaBoyData) -> void:
	selected_metaboy = metaboy

func get_selected_metaboy() -> MetaBoyData:
	return selected_metaboy

func is_dark_screen_body(body_type: String, collection: int = Collection.OG) -> bool:
	if collection == Collection.OG:
		return body_type in DARK_SCREEN_BODIES
	elif collection == Collection.STX:
		return body_type in DARK_SCREEN_STX_BODIES
	
	return false

func get_face_light_version(face_type: String, collection: int = Collection.OG) -> Resource:
	var path = ""
	if collection == Collection.OG:
		path = "res://MetaBoy/spritesheets/Face/" + face_type + "-White.png"
	elif collection == Collection.STX:
		path = "res://MetaBoy/spritesheets_stx/Face/" + face_type + "-White.png"
	
	if path.empty():
		return null
	
	if ResourceLoader.exists(path):
		return load(path)
	
	return null

func clear_loopring_data() -> void:
	user_nfts_loopring.clear()

func clear_stx_data() -> void:
	user_nfts_stacks.clear()

const STX_METADATA_PATH = "res://MetaBoy/Metadata/metaboy_stx.json"
var stx_metadata_json = {}
# Loads the metadata for the MetaBoy STX collection.
func load_stx_metadata_json():
	var file = File.new()
	file.open(STX_METADATA_PATH, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		printerr("Error loading JSON file: " + str(STX_METADATA_PATH))
		return null
	stx_metadata_json = result_json.result
	return result_json.result

const OG_METADATA_PATH = "res://MetaBoy/Metadata/metaboy_og.json"
var og_metadata_json = {}
# Loads the metadata for the MetaBoy OG collection.
func load_og_metadata_json():
	var file = File.new()
	file.open(OG_METADATA_PATH, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		printerr("Error loading JSON file: " + str(OG_METADATA_PATH))
		return null
	og_metadata_json = result_json.result
	return result_json.result

const OG_TOKEN_ID_MAP_PATH = "res://MetaBoy/Metadata/metaboy_og_token_id_map.json"
var og_token_id_map_json = {}
func load_og_token_id_map_json():
	var file = File.new()
	file.open(OG_TOKEN_ID_MAP_PATH, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		printerr("Error loading JSON file: " + str(OG_TOKEN_ID_MAP_PATH))
		return null
	og_token_id_map_json = result_json.result
	return result_json.result

# Get the corresponding ID for a given OG MetaBoy token address
func get_og_id_from_token(token_address: String) -> int:
	if !og_token_id_map_json.empty():
		return og_token_id_map_json.get(token_address, -1)
	return -1

# The iconics in the OG collection are #9,981 to #10,000
func is_iconic_og(nft_id: int) -> bool:
	return 9981 <= nft_id and nft_id <= 10000

# Get the metadata for an OG MetaBoy
func get_og_metadata_for_token(nft_id_address: String) -> Dictionary:
	var nft_id = get_og_id_from_token(nft_id_address)
	return get_og_metadata_for_id(nft_id)

func get_og_metadata_for_id(nft_id: int) -> Dictionary:
	var metadata = {}
	
	if !og_metadata_json.empty():
		# Assumes the metadata is ordered by ID
		metadata = og_metadata_json[nft_id - 1]
	
	return metadata

# Get the metadata for a STX MetaBoy
func get_stx_metadata_for_id(nft_id: int) -> Dictionary:
	var metadata = {}
	
	if !stx_metadata_json.empty():
		# Assumes the metadata is ordered by ID
		metadata = stx_metadata_json[nft_id - 1]
	
	return metadata

# Generate a random mix of attributes. For testing purposes only.
func get_random_attributes(collection: int = Collection.OG) -> Dictionary:
	var body_list = BODY_TYPES
	if collection == Collection.STX:
		body_list = STX_BODY_TYPES
		
	var face_list = FACE_TYPES
	if collection == Collection.STX:
		face_list = STX_FACE_TYPES
		
	var weapon_list = WEAPON_TYPES
	if collection == Collection.STX:
		weapon_list = STX_WEAPON_TYPES
	
	var back_list = BACK_TYPES
	if collection == Collection.STX:
		back_list = STX_BACK_TYPES
	
	var hat_list = HAT_TYPES
	if collection == Collection.STX:
		hat_list = STX_HAT_TYPES
	
	var neck_list = NECK_TYPES
	if collection == Collection.STX:
		neck_list = STX_NECK_TYPES
	
	var waist_list = WAIST_TYPES
	if collection == Collection.STX:
		waist_list = STX_WAIST_TYPES
	
	# Body, Face, and Weapon are mandatory attributes
	var attributes = {
		"Body": pick_random(body_list),
		"Face": pick_random(face_list),
		"Weapon": pick_random(weapon_list)
	}
	
	# 50% chance for all other attributes
	if randf() < 0.5:
		attributes["Back"] = pick_random(back_list)
	if randf() < 0.5:
		attributes["Hat"] = pick_random(hat_list)
	if randf() < 0.5:
		attributes["Neck"] = pick_random(neck_list)
	
	if randf() < 0.5:
		attributes["Waist"] = pick_random(waist_list)
	
	return attributes

func pick_random(array: Array):
	if array.empty():
		return null
	
	return array[randi() % array.size()]
