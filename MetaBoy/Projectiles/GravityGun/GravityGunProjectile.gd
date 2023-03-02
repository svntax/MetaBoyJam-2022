extends ShotProjectile

onready var sprite = $Sprite
onready var explosion_area = $ExplosionArea
onready var explode_sound = $ExplodeSound
onready var animation_player = $AnimationPlayer
onready var lightning_effects = $LightningEffects
onready var spawn_position = self
onready var player = get_tree().get_nodes_in_group("Players")[0]
# TODO: temporary, replace with electric explosion
onready var explosion_particles = $ExplosionParticles

func _ready():
	animation_player.play("moving", -1, 1.25)
	lightning_effects.hide()

# Overridden, this projectile simply rotates towards the given vector
func set_direction(dir: Vector2) -> void:
	sprite.rotation = dir.angle()

func set_spawn_position(pos: Node2D) -> void:
	spawn_position = pos

func _physics_process(delta):
	._physics_process(delta)
	if alive and spawn_position != self:
		if !lightning_effects.visible:
			lightning_effects.call_deferred("show")
		for lightning in lightning_effects.get_children():
			lightning.set_start_point(spawn_position.global_position)
			lightning.set_end_point(lightning.global_position)
			lightning.create_segments()
			lightning.generate_offsets()
			lightning.set_fluctuating(true)
	else:
		for lightning in lightning_effects.get_children():
			lightning.set_fluctuating(false)
		lightning_effects.hide()

# Overridden, will detonate and deal damage to surrounding objects
func _handle_object_entered(other) -> void:
	if source_shooter != null and other == source_shooter:
		return
	
	if not alive:
		return
	
	if other.is_in_group("Powerups") or other.is_in_group("Debris"):
		return
	
	if other.is_in_group("OneWayObjects") and velocity.y <= 0:
		return
	
	explode()

# Overridden for custom effect
func take_hit() -> void:
	explode()

func explode() -> void:
	if not alive:
		return
	alive = false
	if player.gravity_gun_projectile_ref == self:
		player.gravity_gun_projectile_ref = null
	collision_layer = 0
	collision_mask = 0
	body.hide()
	explode_sound.play()
	explosion_particles.emitting = true
	var damage_data = {
		"source_object": self,
		"damage_amount": 10
	}
	for body in explosion_area.get_overlapping_bodies():
		if body == self:
			continue
		if body.has_method("take_damage"):
			body.take_damage(damage_data)
		elif body.has_method("take_hit"):
			body.take_hit()
	for area in explosion_area.get_overlapping_areas():
		if area == self:
			continue
		if area.has_method("take_damage"):
			area.take_damage(damage_data)
		elif area.has_method("take_hit"):
			area.take_hit()

func _on_ExplodeSound_finished():
	destroy()

func _on_VisibilityNotifier2D_screen_exited():
	destroy()

# Overridden to also remove reference to the player
func destroy() -> void:
	if player.gravity_gun_projectile_ref == self:
		player.gravity_gun_projectile_ref = null
	queue_free()
