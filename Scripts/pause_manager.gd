extends Node

var paused_position = Vector3.ZERO
@onready var player = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		player = get_tree().get_first_node_in_group("player")
		if !player:
			return
		
		if !get_tree().paused:
			# Store position and clear velocity only if in air
			if !player.is_on_floor():
				player.velocity = Vector3.ZERO
				paused_position = player.position
				player.is_glitched = false
			
			# Pause game regardless of being in air or on ground
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			# Unpausing - always unpause first
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
			# If we were in air when paused, restore position and enable glitch
			if !player.is_on_floor():
				player.position = paused_position
				player.velocity = Vector3.ZERO
				player.is_glitched = true
