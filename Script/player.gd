extends CharacterBody2D

@onready var animator = $AnimatedSprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var direction = 0

var is_it = false
@onready var star_sprite = $Sprite2D
var touched = false

@export var player_id := 1:
	set(id):
		player_id = id
		$InputSynchronizer.set_multiplayer_authority(id)

var do_jump = false
var _is_on_floor = true

func _ready() -> void:
	if player_id == 1:
		is_it = true
	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_is_on_floor = is_on_floor()
		handle_movement(delta)
	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		handle_animation(delta)
	
	if is_it:
		star_sprite.visible = true
	else:
		star_sprite.visible = false
	
	move_and_slide()

func handle_movement(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if do_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		do_jump = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = $InputSynchronizer.input_direction
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_animation(_delta):
	if direction > 0:
		animator.flip_h = false
	elif direction < 0:
		animator.flip_h = true
	
	if _is_on_floor:
		if direction == 0:
			animator.play("idle")
		else:
			animator.play("walk")
	else:
		animator.play("jump")

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if !_area.get_parent().is_it and is_it and !touched:
		touched = true
		is_it = false
		_area.get_parent().touched = true
		_area.get_parent().is_it = true


func _on_area_2d_area_exited(_area: Area2D) -> void:
	touched = false
