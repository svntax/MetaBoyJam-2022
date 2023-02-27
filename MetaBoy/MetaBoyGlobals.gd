extends Node

# All attribute types for MetaBoys
const BACK_TYPES = ["Angel-Wings", "Demon-Wings", "Fireball", "Golden-Wings", "Sai-Backpack", "Sword-Backpack"]
const BODY_TYPES = ["Angel", "Assassin", "Astronaut", "Biker", "Bloodied", "Bread-Slice", "Camouflage", "Country", "Cowboy", "Demon", "Explorer", "Galaxy", "Gentleman", "Goth-Girl", "Lifeguard", "Light-Blue", "Lizard", "Lumberjack", "Mom-Jeans", "Monk", "Monster-Suit", "Muscular-Warrior", "Neon-Solid", "Neon-Transparent", "Nobleman", "Open-Jacket", "Prisoner", "Red-Dress", "Roman-Gladiator", "Samurai", "Santa-Claus", "Schoolboy", "Schoolgirl", "Stealth", "Stone", "Stripped", "Suit", "Superhero", "Supervillain", "Survivor", "Suspenders", "Tiger", "Turtle", "Underwater-Suit", "Water", "Watermelon", "Wood", "Yellow-Overalls", "Yellow", "Zombie"]
const FACE_TYPES = ["404-Face", "6_6", "Angel-Smile", "Angry", "Bearded-Cowboy", "Big-Chin", "Big-Moustashe", "Big-Teeth", "Bubblegum", "Cat", "Confused", "Crazy", "Crying", "Cyclops", "Demon", "Dog", "Double-Chin", "Dumb-Laugh", "Empty-Face", "Female-Villian", "Furious-Face", "Galaxy", "Glasses", "Goatee", "Got-You", "Grinding-Teeth", "Handsome-Face", "Happy-Clown", "Happy-Face", "Happy-Girl", "Hitman-Face", "Holding-a-Laugh", "Huge-Smile", "Loud-Crying", "Monocle", "Monster", "Mustashe-Hipster", "Neon-Face", "OoO", "Pig", "Rosy-Cheeks", "Sad-Zombie", "Sad", "Scary-Clown", "Seducing", "Serious", "Skull", "Smiling-Skull", "Smiling-Zombie", "Snobby-Kid", "Super-Angry", "Suprised", "Sweet", "Teeth-Smile", "Tongue-out", "Unibrow-Bandit", "Viper", "Whatever"]
const HAT_TYPES = ["Arrow-Through-Head", "Astronaut-Helmet", "Axe-Hat", "Bear-Hat", "Beret-Hat", "Bitcoin-Hat", "Bunny-Ears", "Cat-Ears", "Chefs-Hat", "Cowboy-Hat", "Crown", "Dark Purple Wizard Hat", "Dark-Hoodie", "Detective-Hat", "Ethereum-Hat", "Fedora", "Green-Headphones", "Green-Mowhawk", "Halo", "Hat-Blue", "Hat-Orange", "Jester-Hat", "Leafs", "Lion-Hat", "Medic-Hat", "Pirate-Hat", "Plague -Doctor-Mask", "Plague-Doctor-Hat", "Purple Wizard Hat", "Purple-Mowhawk", "Red-Mowhawk", "Ribbon", "Russian-Hat", "Samurai-Helmet", "Sea-Captain-Hat", "Skull-Top-Hat", "Steampunk-Hat", "Underwater-Helmet", "Viking-Helmet", "Warrior-Helmet", "Winged-Helmet", "Wizard-Hat", "Xmas-Hat", "Yellow Hat"]
const NECK_TYPES = ["Arrow-Quiver", "Binoculars", "Black-Scarf", "Blue-Bandana", "Dog-Tags", "Fur-Cape", "Medallion-Necklace", "Red-Bandana", "Red-Cape", "Red-Scarf", "Shoulder-Pads", "Skull-Bandana", "Teeth-Necklace"]
const WAIST_TYPES = ["Belt-empty-Holsters", "Belt-with-Both-Pistols", "Belt-with-Left-Pistol", "Belt-with-Right-Pistol", "Chain-Belt", "Champion-Belt", "Fighter-Belt", "Grenade-Belt", "Potion-Belt", "Satchel", "Warrior-Belt"]
const WEAPON_TYPES = ["Axe-and-Shield", "Bazooka", "Blade", "Bomb", "Bow-and-Arrow", "Bow", "Boxing-Gloves", "Chainsaw", "Cowboy-Both-Pistols", "Cowboy-Left-Pistol", "Cowboy-Right-Pistol", "Crowbar", "Daggers", "Dark-Staff", "Dynamite-Stick", "Elder-Wand", "Energy-Sword", "Flamethrower", "Golden-Blades", "Golden-Sword", "Gravity-Gun", "Harpoon", "Hook", "Katana", "Kunai", "Laser-Guns", "Lightning", "Love", "Medusa_s-Head", "Neon-Solid", "Neon-Transparent", "Retro-Futuristic-Rifle", "Robot-Claw", "Sai", "Side-Gun", "Slingshot", "Snail-Shell", "Sniper", "Spear-and-Shield", "Trident", "Wooden-Staff", "Wrist-Straps", "Yatagan", "Zombie-Hands"]

# These bodies need the light version of a face if applicable.
const DARK_SCREEN_BODIES = ["Bloodied", "Bread-Slice", "Camouflage", "Demon",
"Galaxy", "Goth-Girl", "Lizard", "Monk", "Muscular-Warrior", "Neon-Solid", 
"Open-Jacket", "Red-Dress", "Stone", "Supervillain", "Survivor", "Suspenders",
"Tiger", "Turtle", "Water", "Watermelon", "Wood", "Yellow", "Zombie"]

# TODO temp testing
var test_metaboy = {
	"Body": "Superhero",
	"Face": "Loud-Crying",
	"Weapon": "Yatagan",
}
const WEAPONS_TO_TEST = ["Yatagan", "Energy-Sword", "Bomb", "Dynamite-Stick", "Snail-Shell", "Elder-Wand", "Bazooka"]
var current_weapon_index = 0

# The MetaBoy the user has selected.
var default_metaboy = {
	"Body": "Superhero",
	"Face": "Loud-Crying",
	"Weapon": "Yatagan"
}
var selected_metaboy = {} setget set_selected_metaboy, get_selected_metaboy

func set_selected_metaboy(metaboy_attributes: Dictionary) -> void:
	selected_metaboy = metaboy_attributes

func get_selected_metaboy() -> Dictionary:
	return selected_metaboy

func is_dark_screen_body(body_type: String) -> bool:
	return body_type in DARK_SCREEN_BODIES

func get_face_light_version(face_type: String) -> Resource:
	var path = "res://MetaBoy/spritesheets/Face/" + face_type + "-White.png"
	if ResourceLoader.exists(path):
		return load(path)
	
	return null

# Generate a random mix of attributes. For testing purposes only.
func get_random_attributes() -> Dictionary:
	# Body, Face, and Weapon are mandatory attributes
	var attributes = {
		"Body": pick_random(BODY_TYPES),
		"Face": pick_random(FACE_TYPES),
		"Weapon": pick_random(WEAPON_TYPES)
	}
	# 50% chance for all other attributes
	if randf() < 0.5:
		attributes["Back"] = pick_random(BACK_TYPES)
	if randf() < 0.5:
		attributes["Hat"] = pick_random(HAT_TYPES)
	if randf() < 0.5:
		attributes["Neck"] = pick_random(NECK_TYPES)
	# TODO: Waist type is mapped to specific weapon types(?)
	if randf() < 0.5:
		attributes["Waist"] = pick_random(BACK_TYPES)
	
	return attributes

func pick_random(array: Array):
	if array.empty():
		return null
	
	return array[randi() % array.size()]
