extends Node2D

onready var health_ui = get_node("%HealthUI")
onready var game_over_menu = get_node("%GameOverMenu")
onready var upgrades_menu = get_node("%UpgradeMenu")
onready var time_label = get_node("%TimeLabel")
onready var score_label = get_node("%ScoreLabel")
onready var max_jumps_label = get_node("%JumpCountLabel")
onready var camera = get_node("%PlayerCamera")
onready var player = $MetaBoy
onready var game_music = $GameMusic
onready var upgrade_jingle = $UpgradeJingle

# In seconds
onready var time_left = 20
onready var countdown_timer: Timer

# Every x points, bring up the upgrades menu
onready var upgrade_interval = 100
onready var next_upgrade_target = upgrade_interval
onready var current_upgrade_score = 0

func _ready():
	Globals.start_new_game()
	update_score()
	Globals.connect("current_score_changed", self, "update_score")
	
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1
	countdown_timer.one_shot = true
	countdown_timer.connect("timeout", self, "_on_countdown_timer_timeout")
	time_label.add_child(countdown_timer)
	countdown_timer.start()
	update_time()
	
	health_ui.connect("out_of_hp", self, "_on_death")
	upgrades_menu.connect("menu_closed", self, "_on_upgrades_menu_closed")
	player.connect("health_changed", self, "_on_player_health_changed")
	player.connect("time_added", self, "_on_time_added")
	player.connect("damage_taken", self, "_on_player_damage_taken")
	player.connect("max_health_increased", self, "_on_player_max_health_increased")
	player.connect("max_jumps_changed", self, '_on_player_max_jumps_changed')
	
	game_music.play()

func _on_player_health_changed(new_hp: int) -> void:
	health_ui.set_health(new_hp)

func _on_player_max_health_increased() -> void:
	health_ui.add_heart()

func _on_player_damage_taken(new_hp: int) -> void:
	if new_hp > 0:
		camera.screenshake(0.4, 2, 0.05)

func _on_time_added(amount: int) -> void:
	time_left += amount
	update_time()

func _on_player_max_jumps_changed(new_max_jumps: int) -> void:
	max_jumps_label.set_text("Jumps: " + str(new_max_jumps))

# Syncs the time label to display time_left
func update_time() -> void:
	time_label.set_text("TIME LEFT: " + str(time_left))

# Syncs the score label to display the global current_score
func update_score() -> void:
	score_label.set_text("SCORE: " + str(Globals.current_score))
	current_upgrade_score = Globals.current_score
	if current_upgrade_score >= next_upgrade_target:
		next_upgrade_target += upgrade_interval
		upgrades_menu.display()
		upgrade_jingle.play()

func _on_countdown_timer_timeout() -> void:
	if not player.is_alive():
		return
	
	time_left -= 1
	update_time()
	if time_left > 0:
		countdown_timer.start()
	else:
		ran_out_of_time()

func _on_upgrades_menu_closed() -> void:
	upgrade_jingle.stop()

func ran_out_of_time() -> void:
	player.kill()
	game_over_menu.header_label.set_text("OUT OF TIME!")
	game_over_menu.display()
	game_music.stop()

func _on_death() -> void:
	game_over_menu.display()
	game_music.stop()
