extends KinematicBody2D

const LaserShotHoming = preload("res://Enemies/RobotFlying/LaserShotHoming.tscn")
const BrokenHeadPiece = preload("res://Enemies/RobotFlying/RobotFlyingHead.tscn")
const BrokenBodyPiece = preload("res://Enemies/RobotFlying/RobotFlyingBody.tscn")

const ClockPowerup = preload("res://Powerups/ClockPowerup.tscn")

export (bool) var facing_left = false
export (bool) var random_direction = false

const SCORE_VALUE = 20

onready var animation_player = $AnimationPlayer
onready var effects_player = $EffectsPlayer
onready var attack_cooldown_timer = $AttackCooldown
onready var telegraph_timer = $TelegraphTimer
onready var body = $Body
onready var projectile_spawn = $Body/ProjectileSpawn
onready var head_spawn = $Body/HeadSpawn
onready var body_spawn = $Body/BodySpawn

onready var shoot_sound = $ShootSound
onready var explode_sound = $ExplosionSound

onready var alive = true
onready var attack_cooldown = 1
onready var direction = 1 # 1 = right, -1 = left
onready var speed = 100
onready var velocity = Vector2()

onready var original_pos = body.position
onready var t = 0

onready var player = get_tree().get_nodes_in_group("Players")[0]

func _ready():
	attack_cooldown_timer.start(rand_range(1, 2))
	effects_player.play("flying")
	if random_direction:
		if randf() < 0.5:
			set_direction(1)
		else:
			set_direction(-1)
	else:
		if facing_left:
			set_direction(-1)
		else:
			set_direction(1)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.normal
		if normal.x != 0:
			set_direction(normal.x)

func _process(delta):
	# Manual hovering movement
	t += delta
	if t > 360:
		t = 0
	body.position.y = original_pos.y + 3 * cos(t*8)

func set_direction(dir: int) -> void:
	var new_dir = sign(dir)
	if new_dir == 0:
		new_dir = 1
	direction = dir
	body.scale.x = direction
	velocity.x = speed * direction

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
	explode_sound.play()

func shoot() -> void:
	animation_player.play("shoot")
	shoot_sound.play()
	
	var laser = LaserShotHoming.instance()
	laser.source_shooter = self # To prevent the laser from hitting this robot
	laser.global_position = projectile_spawn.global_position
	get_tree().get_root().get_node("Gameplay").add_child(laser)
	laser.aim_towards(player)

func can_shoot() -> bool:
	if not alive:
		return false
	
	var dist = abs(player.global_position.y - global_position.y)
	return dist <= 360

func spawn_broken_pieces(source_obj) -> void:
	var dir = sign(global_position.x - source_obj.global_position.x)
	
	# Spawn the body
	var debris_body = BrokenBodyPiece.instance()
	debris_body.global_position = body_spawn.global_position
	get_tree().get_root().get_node("Gameplay").add_child(debris_body)
	debris_body.scale.x = direction
	# Knock back in the direction away from the player
	var vx = rand_range(48, 72) * dir
	var vy = rand_range(-48, -24)
	debris_body.apply_central_impulse(Vector2(vx, vy))
	
	# Spawn the head
	var debris_head = BrokenHeadPiece.instance()
	debris_head.global_position = head_spawn.global_position
	get_tree().get_root().get_node("Gameplay").add_child(debris_head)
	debris_head.scale.x = direction
	# Knock back in the direction away from the player
	vx = rand_range(48, 72) * dir
	vy = rand_range(-48, -24)
	debris_head.apply_central_impulse(Vector2(vx, vy))

func spawn_powerup() -> void:
	var powerup = ClockPowerup.instance()
	powerup.global_position = global_position
	get_tree().get_root().get_node("Gameplay").add_child(powerup)
	powerup.set_type_small() # Robots spawn the smaller time pickups

func _on_TelegraphTimer_timeout():
	if can_shoot():
		shoot()
	attack_cooldown_timer.start(attack_cooldown)

func _on_AttackCooldown_timeout():
	animation_player.play("telegraph")
	telegraph_timer.start()

func _on_ExplosionSound_finished():
	queue_free()
