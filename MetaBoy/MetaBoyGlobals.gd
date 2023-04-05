extends Node

# Address for the original MetaBoy collection smart contract
const CONTRACT_OG = "0x1D006a27BD82E10F9194D30158d91201E9930420"
# For storing the response array of NFT metadata from Loopring
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

# These bodies need the light version of a face if applicable.
# OG Collection
const DARK_SCREEN_BODIES = ["Bloodied", "Bread-Slice", "Camouflage", "Demon",
"Galaxy", "Goth-Girl", "Lizard", "Monk", "Muscular-Warrior", "Neon-Solid", 
"Open-Jacket", "Red-Dress", "Stone", "Supervillain", "Survivor", "Suspenders",
"Tiger", "Turtle", "Water", "Watermelon", "Wood", "Yellow", "Zombie"]
# STX Collection
const DARK_SCREEN_STX_BODIES = ["Ape", "Superhero"] + DARK_SCREEN_BODIES

# TODO temp testing
var test_metaboy = {
	"Body": "Ape",
	"Face": "Got You",
	"Weapon": "STX-Blaster",
	"Hat": "Green Headphones"
}
const WEAPONS_TO_TEST = ["Yatagan", "Energy-Sword", "Bomb", "Dynamite-Stick", "Snail-Shell", "Elder-Wand", "Bazooka", "Laser-Guns", "Gravity-Gun", "Retro-Futuristic-Rifle", "Lightning"]
var current_weapon_index = 0

# The MetaBoy the user has selected.
var default_metaboy = {
	"Body": "Superhero",
	"Face": "Loud-Crying",
	"Weapon": "Yatagan",
	"Collection": Collection.OG
}
var selected_metaboy = {} setget set_selected_metaboy, get_selected_metaboy

func set_selected_metaboy(metaboy_attributes: Dictionary) -> void:
	selected_metaboy = metaboy_attributes

func get_selected_metaboy() -> Dictionary:
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

func clear_data() -> void:
	user_nfts_loopring = []

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
