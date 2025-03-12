extends RayCast3D

@export var selectedObject:Node3D
@export var heldObject:Node3D
@onready var rayCastEnd = $RayCastEnd
@export var rayPos:Vector3


func _ready():
	pass

func _unhandled_input(event):
	# Check if the player interacts
	if Input.is_action_just_pressed("interact") and selectedObject != null:
		if selectedObject.has_method("interact") and is_colliding():
			selectedObject.interact()
			return
		# This is to drop held items
		if heldObject:
			selectedObject.interact()
			return


func _process(_delta):
	# Check if the raycast is colliding and that we aren't holding something
	if heldObject == null:
		if is_colliding():
			# check if the object selected has changed
			if selectedObject != get_collider():
				ChangeSelected(get_collider())
		else:
			# If we are not colliding with any object
			if selectedObject:
				ChangeSelected(null)
	# Move RayPos spot
	if is_colliding():
		rayPos = get_collision_point()
	else:
		rayPos = rayCastEnd.global_position
	
func ChangeSelected(new):
	var old = selectedObject
	
	selectedObject = new
	print(selectedObject)
	#emit_signal("selectedChange", old, new)
	
