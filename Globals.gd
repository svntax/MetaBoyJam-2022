extends Node

signal current_score_changed()

const API_ENV_PATH = "res://Configs/env.cfg"
var loopring_api_key = ""

const MAX_HEALTH_CAP = 7

var current_score = 0
var high_score = 0
var reached_new_high_score = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	# Read Loopring API key
	var env_config = ConfigFile.new()
	var err = env_config.load(API_ENV_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("env.cfg file is missing")
	elif err != OK:
		printerr("Error when attempting to load env.cfg")
	else:
		loopring_api_key = env_config.get_value("API_KEYS", "loopring")

func start_new_game():
	reached_new_high_score = false
	current_score = 0

func add_score(value: int) -> void:
	if value < 0:
		value = 0
	set_score(current_score + value)

func set_score(new_score: int) -> void:
	current_score = new_score
	if current_score > high_score:
		high_score = current_score
		reached_new_high_score = true
	emit_signal("current_score_changed")
