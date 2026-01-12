extends RigidBody3D
class_name Player
@export_range(750,2500) var force :=1000.0
@export var torque := 100
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("space"):
		apply_central_force(basis.y *delta *force)
	if Input.is_action_pressed("rleft"):
		apply_torque(Vector3(0,0,delta*torque))
	if Input.is_action_pressed("rright"):
		apply_torque(Vector3(0,0,-delta*torque))


func _on_body_entered(body: Node) -> void:
	if "goal" in body.get_groups():
		complete_level(body.file_path)
	if "surroundings" in body.get_groups():
		crash_sequence()
		
func crash_sequence():
	print("KABOOM")
	await get_tree().create_timer(2.5)
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_level):
	get_tree().change_scene_to_file.call_deferred(next_level)
