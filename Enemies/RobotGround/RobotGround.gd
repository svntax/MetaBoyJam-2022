extends KinematicBody2D

const LaserShot = preload("res://Enemies/RobotGround/LaserShot.tscn")

export (bool) var facing_left = false

const SCORE_VALUE = 10

onready var animation_player = $AnimationPlayer
onready var attack_cooldown_timer = $AttackCooldown
onready var telegraph_timer = $TelegraphTimer
onready var body = $Body
onready var projectile_spawn = $Body/ProjectileSpawn

onready var attack_cooldown = 1
onready var direction = 1 # 1 = right, -1 = left

func _ready():
	attack_cooldown_timer.start(rand_range(1, 3))
	if facing_left:
		set_direction(-1)

func set_direction(dir: int) -> void:
	var new_dir = sign(dir)
	if new_dir == 0:
		new_dir = 1
	direction = dir
	body.scale.x = direction

func take_damage(damage_data: Dictionary) -> void:
	var source_obj = damage_data.get("source_object", null)
	call_deferred("destroy", source_obj)

func destroy(source_obj) -> void:
	# TODO: debris pieces
	Globals.add_score(SCORE_VALUE)
	queue_free()

func shoot() -> void:
	animation_player.play("shoot")
	var laser = LaserShot.instance()
	laser.source_shooter = self # To prevent the laser from hitting this robot
	laser.global_position = projectile_spawn.global_position
	get_tree().get_root().get_node("Gameplay").add_child(laser)
	laser.set_direction(direction)

func _on_TelegraphTimer_timeout():
	shoot()
	attack_cooldown_timer.start(attack_cooldown)

func _on_AttackCooldown_timeout():
	animation_player.play("telegraph")
	telegraph_timer.start()
