extends ThrownProjectile

onready var sprite = $Weapon
onready var animation_player = $AnimationPlayer
onready var explosion_particles = $ExplosionParticles
onready var explode_sound = $ExplodeSound
onready var explosion_area = $ExplosionArea

func _ready():
	damage_data = {
		"source_object": self,
		"damage_amount": 10
	}

func _on_collide(_collision) -> void:
	explode()

func take_damage(_damage_data: Dictionary) -> void:
	explode()

func take_hit() -> void:
	explode()

func explode() -> void:
	if active:
		active = false
		collision_layer = 0
		collision_mask = 0
		sprite.hide()
		explode_sound.play()
		animation_player.play("explode")
		for body in explosion_area.get_overlapping_bodies():
			if body == self:
				continue
			if body.has_method("take_damage"):
				body.take_damage(damage_data)
			elif body.has_method("take_hit"):
				body.take_hit()
		for area in explosion_area.get_overlapping_areas():
			if area.has_method("take_damage"):
				area.take_damage(damage_data)
			elif area.has_method("take_hit"):
				area.take_hit()

func flip_direction() -> void:
	scale.x *= -1

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
