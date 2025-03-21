extends CharacterBody3D

@onready var _camera := $CameraPivot/Camera3D as Camera3D
@onready var _camera_pivot := $CameraPivot as Node3D
var direction = Vector3.ZERO
var is_glitched = false

@export_range(0.0, 1.0) var mouse_sensitivity = 0.002
@export var tilt_limit = deg_to_rad(75) 

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared. 
@export var fall_acceleration = 75
@export var jump_impulse = 20

var target_velocity = Vector3.ZERO

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var cam_yaw = _camera_pivot.rotation.y
		var rotated_direction = Basis(Vector3.UP, cam_yaw) * direction

		target_velocity.x = rotated_direction.x * speed
		target_velocity.z = rotated_direction.z * speed
	else:
		target_velocity.x = 0
		target_velocity.z = 0

	# Only apply gravity if not glitched
	if !is_glitched and !is_on_floor():
		target_velocity.y -= delta * fall_acceleration

	velocity = target_velocity
	move_and_slide()

	# Reset glitch if we touch the ground
	if is_on_floor() and is_glitched:
		is_glitched = false

func _unhandled_input(event: InputEvent) -> void:
	direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Allow jumping even when glitched
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_glitched):
		target_velocity.y = jump_impulse
		is_glitched = false  # Remove glitch effect when jumping

	if event is InputEventMouseMotion and !get_tree().paused:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down. 
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity
