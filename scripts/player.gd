extends CharacterBody2D
# ─── movement tuning ─────────────────────────────────────────────────────
@export var MAX_SPEED    : float = 100.0
@export var ACCELERATION : float = 300.0
@export var FRICTION     : float = 1200.0

# ─── animation setup ─────────────────────────────────────────────────────
# naming scheme:  idle_right / idle_forward / idle_back
#                 walk_right / walk_forward / walk_back
@export var idle_prefix : String = "idle_"
@export var walk_prefix : String = "walk_"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _facing : String = "forward"   # remember last facing dir (forward, back, right, left)

func _physics_process(delta: float) -> void:
	var input_dir := _get_input_direction()
	var desired   := input_dir * MAX_SPEED

	# momentum
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(desired, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	_update_animation(input_dir)
	move_and_slide()

# ------------------------------------------------------------------------
func _get_input_direction() -> Vector2:
	var d := Vector2.ZERO
	if Input.is_action_pressed("right"): d.x += 1
	if Input.is_action_pressed("left"):  d.x -= 1
	if Input.is_action_pressed("down"):  d.y += 1    # Godot Y-axis points down
	if Input.is_action_pressed("up"):    d.y -= 1
	return d.normalized()

func _update_animation(dir: Vector2) -> void:
	# 1. Work out the current facing
	if dir != Vector2.ZERO:
		_facing = _dir_to_facing(dir)

	# 2. Choose animation name
	var base   := walk_prefix if dir != Vector2.ZERO else idle_prefix
	var facing := _facing
	var play_anim: String

	# For LEFT we reuse the *right* clips and flip them
	if facing == "left":
		play_anim      = base + "right"
		anim.flip_h    = true
	elif facing == "right":
		play_anim      = base + "right"
		anim.flip_h    = false
	else:  # forward / back
		play_anim      = base + facing
		anim.flip_h    = false

	if anim.animation != play_anim:
		anim.play(play_anim)

func _dir_to_facing(dir: Vector2) -> String:
	# Decide which axis dominates; ties favour horizontal so left/right feel snappier
	if abs(dir.x) >= abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "forward" if dir.y > 0 else "back"
