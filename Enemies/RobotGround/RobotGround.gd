extends KinematicBody2D

const LaserShot = preload("res://Enemies/RobotGround/LaserShot.tscn")
const BrokenHeadPiece = preload("res://Enemies/RobotGround/RobotGroundHead.tscn")
const ClockPowerup = preload("res://Powerups/ClockPowerup.tscn")

export (bool) var facing_left = false
export (bool) var random_direction = false

const SCORE_VALUE = 10

onready var animation_player = $AnimationPlayer
onready var attack_cooldown_timer = $AttackCooldown
onready var telegraph_timer = $TelegraphTimer
onready var body = $Body
onready var body_dead = $BodyDead
onready var projectile_spawn = $Body/ProjectileSpawn

onready var shoot_sound = $ShootSound
onready var explode_sound = $ExplosionSound

onready var alive = true
onready var attack_cooldown = 1
onready var direction = 1 # 1 = right, -1 = left

onready var player = get_tree().get_nodes_in_group("Players")[0]

func _ready():
	attack_cooldown_timer.start(rand_range(1, 2))
	if facing_left:
		set_direction(-1)
	if random_direction:
		if randf() < 0.5:
			set_direction(1)
		else:
			set_direction(-1)

func set_direction(dir: int) -> void:
	var new_dir = sign(dir)
	if new_dir == 0:
		new_dir = 1
	direction = dir
	body.scale.x = direction

func take_damage(damage_data: Dictionary) -> void:
	var source_obj = damage_data.get("source_object", null)
	alive = false
	call_deferred("destroy", source_obj)

func destroy(source_obj) -> void:
	spawn_broken_pieces(source_obj)
	spawn_powerup()
	if player.hp > 0:
		Globals.add_score(SCORE_VALUE)
	collision_layer = 0
	collision_mask = 0
	body.hide()
	body_dead.show()
	explode_sound.play()

func shoot() -> void:
	animation_player.play("shoot")
	shoot_sound.play()
	
	var laser = LaserShot.instance()
	laser.source_shooter = self # To prevent the laser from hitting this robot
	laser.global_position = projectile_spawn.global_position
	get_tree().current_scene.add_child(laser)
	laser.set_direction(direction)

func can_shoot() -> bool:
	if not alive:
		return false
	
	var dist = abs(player.global_position.y - global_position.y)
	return dist <= 360

func spawn_broken_pieces(source_obj) -> void:
	var debris = BrokenHeadPiece.instance()
	debris.global_position = global_position
	get_tree().current_scene.add_child(debris)
	debris.scale.x = direction
	
	# Knock back in the direction away from the player
	var dir = sign(global_position.x - source_obj.global_position.x)
	var vx = rand_range(48, 72) * dir
	var vy = rand_range(-48, -24)
	debris.apply_central_impulse(Vector2(vx, vy))

func spawn_powerup() -> void:
	var powerup = ClockPowerup.instance()
	powerup.global_position = global_position
	get_tree().current_scene.add_child(powerup)
	powerup.set_type_small() # Robots spawn the smaller time pickups

func _on_TelegraphTimer_timeout():
	if can_shoot():
		shoot()
	attack_cooldown_timer.start(attack_cooldown)

func _on_AttackCooldown_timeout():
	animation_player.play("telegraph")
	telegraph_timer.start()

func _on_ExplosionSound_finished():
	pass# queue_free()
