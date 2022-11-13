extends Node2D

onready var health_ui = get_node("%HealthUI")
onready var game_over_menu = get_node("%GameOverMenu")
onready var time_label = get_node("%TimeLabel")
onready var player = $MetaBoy

# In seconds
onready var time_left = 20
onready var countdown_timer: Timer

func _ready():
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1
	countdown_timer.one_shot = true
	countdown_timer.connect("timeout", self, "_on_countdown_timer_timeout")
	time_label.add_child(countdown_timer)
	countdown_timer.start()
	update_time()
	
	health_ui.connect("out_of_hp", self, "_on_death")
	player.connect("health_changed", self, "_on_player_health_changed")
	player.connect("time_added", self, "_on_time_added")

func _on_player_health_changed(new_hp: int) -> void:
	health_ui.set_health(new_hp)

func _on_time_added(amount: int) -> void:
	time_left += amount
	update_time()

# Syncs the time label to display time_left
func update_time() -> void:
	time_label.set_text("TIME LEFT: " + str(time_left))

func _on_countdown_timer_timeout() -> void:
	if not player.is_alive():
		return
	
	time_left -= 1
	update_time()
	if time_left > 0:
		countdown_timer.start()
	else:
		ran_out_of_time()

func ran_out_of_time() -> void:
	player.kill()
	game_over_menu.header_label.set_text("OUT OF TIME!")
	game_over_menu.display()

func _on_death() -> void:
	game_over_menu.display()
