extends RigidBody3D
class_name Player
@export_range(750,2500) var force :=1000.0
@export var torque := 100
@export var starting_fuel = 500
var ui : CanvasLayer
var fuel : int:
	set(amt):
		fuel = amt
		ui.update_fuel(amt)
var transitioning :=false
@onready var success: AudioStreamPlayer = $Success
@onready var explosion: AudioStreamPlayer = $Explosion
@onready var rocket: AudioStreamPlayer3D = $Rocket
@onready var center: GPUParticles3D = $center
@onready var left: GPUParticles3D = $left
@onready var right: GPUParticles3D = $right
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles

@onready var success_particles: GPUParticles3D = $SuccessParticles



func _ready() -> void:
	ui = get_tree().get_first_node_in_group("ui")
	fuel = starting_fuel

func _process(delta: float) -> void:
	if not transitioning:
		if Input.is_action_pressed("space"):
			if fuel>0:
				fuel-=1
				apply_central_force(basis.y *delta *force)
				center.emitting=true
				if not rocket.is_playing():
					rocket.play()
		else:
			rocket.stop()
			center.emitting=false
		if Input.is_action_pressed("rleft"):
			apply_torque(Vector3(0,0,delta*torque))
			right.emitting = true
		else:
			right.emitting=false
		if Input.is_action_pressed("rright"):
			apply_torque(Vector3(0,0,-delta*torque))
			left.emitting=true
		else:
			left.emitting=false
		
func _on_body_entered(body: Node) -> void:
	if not transitioning:
		left.emitting=false
		right.emitting = false
		if "goal" in body.get_groups():
			complete_level(body.file_path)
		if "surroundings" in body.get_groups():
			crash_sequence()
		
func crash_sequence():
	explosion.play()
	explosion_particles.emitting = true
	transitioning=true
	left.emitting=false
	right.emitting = false
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_level):
	success.play()
	success_particles.emitting = true
	transitioning=true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file.call_deferred(next_level)
