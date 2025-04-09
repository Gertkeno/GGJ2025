extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const CROUCH_SPEED: float = 2.5
const GROUND_ACCELERATION: float = 40.0
const AIR_ACCELERATION: float = 5.0
const JUMP_VELOCITY: float = 5.5
const ROTATION_SPEED: float = TAU * 2

#region control options
static var camera_sensitivity: float = 1.0
static var y_invert: float = 1.0
static var toggle_crouch: bool = false
static var arcade_mode: bool = true
#endregion

@export var catch_particles: PackedScene
@export var buble_particles: PackedScene

@onready var hurt_timer: Timer = $HurtTimer
@onready var catch_anticipate: Timer = $CatchSwingAnticipation
@onready var net_hitbox: Area3D = $Player/NetHitbox
@onready var animator: AnimationTree = $AnimationTree
var animator_playback: AnimationNodeStateMachinePlayback
@onready var arcade_timer: Timer = $ArcadeTimer
@export var player_mesh: MeshInstance3D
var eye_material: StandardMaterial3D
var crouching: bool = false # for enemy detection
var raised_net: bool = false # for animation
var caught_animals: Array[AnimalDescriptor]
var animals_left: int = -1


func move_toward_angle(value: float, target: float, delta: float) -> float:
	var diff := fmod(target - value, TAU)
	var dir := signf(diff)
	if absf(diff) > PI:
		dir = -dir # angle probably closer in opposite direction

	if absf(diff) > delta:
		return value + dir * delta
	else:
		return target


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var vertical_velocity := velocity.project(up_direction)
	var horizontal_velocity := velocity - vertical_velocity

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and hurt_timer.is_stopped():
		var last_collision := get_last_slide_collision()
		# set respawn point if on *solid* ground
		# This is evil, mayhaps Mac compile?
		if last_collision and last_collision.get_collider().collision_layer == 1:
			set_meta("last_jump", position)
		animator_playback.travel("Jump")
		vertical_velocity = JUMP_VELOCITY * up_direction

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = $CameraPivot.global_basis.orthonormalized() * Vector3(input_dir.x, 0, input_dir.y)

	if hurt_timer.is_stopped():
		var accel: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		var speed: float = CROUCH_SPEED if crouching else SPEED
		horizontal_velocity = horizontal_velocity.move_toward(direction*speed, accel*delta)

		if direction:
			var vis_y_rotation: float = -input_dir.angle() - PI/2.0
			$Player.rotation.y = move_toward_angle($Player.rotation.y, vis_y_rotation, ROTATION_SPEED * delta)
			rotation.y += $CameraPivot.rotation.y
			$CameraPivot.rotation.y = 0.0
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, AIR_ACCELERATION*delta)

	velocity = horizontal_velocity + vertical_velocity

	move_and_slide()


var screen_size: Vector2
func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	eye_material = player_mesh.get_surface_override_material(1)
	if arcade_mode:
		arcade_timer.start()
		$Time.show()
	_init_credits()
	animals_left = _count_all_animals()
	animator_playback = animator.get("parameters/playback")


func _process(delta: float) -> void:
	var controller_direction: Vector2 = Input.get_vector("turn_left", "turn_right", "turn_up", "turn_down")
	if controller_direction:
		var camera_move: Vector2 = controller_direction * PI * delta * camera_sensitivity
		$CameraPivot.rotate_y(-camera_move.x)
		$CameraPivot/SpringArm3D.rotate_x(camera_move.y * y_invert)
		$CameraPivot/SpringArm3D.rotation.x = clampf($CameraPivot/SpringArm3D.rotation.x, -CAMERA_ANGLE_MAX, CAMERA_ANGLE_MAX)
	var speed: float = CROUCH_SPEED if crouching else SPEED
	animator.set("parameters/Walk/WalkSpeed/scale", velocity.length() / speed)
	$Time.set_time(arcade_timer.time_left)


const CAMERA_ANGLE_MAX = deg_to_rad(70)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var camera_move: Vector2 = event.screen_relative / screen_size * -PI * camera_sensitivity

			$CameraPivot.rotate_y(camera_move.x)
			$CameraPivot/SpringArm3D.rotate_x(camera_move.y * y_invert)
			$CameraPivot/SpringArm3D.rotation.x = clampf($CameraPivot/SpringArm3D.rotation.x, -CAMERA_ANGLE_MAX, CAMERA_ANGLE_MAX)
	elif event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var can_swing: bool = hurt_timer.is_stopped() and animator_playback.get_current_node() != &"Swing"
	if event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Settings.show()
		get_tree().paused = true
	elif event.is_action("catch") and can_swing:
		if raised_net == event.is_pressed():
			return
		raised_net = event.is_pressed()
		var final_value: float = 1.0 if raised_net else 0.0
		var raise_tween: Tween = create_tween().set_parallel()
		raise_tween.tween_property(animator, "parameters/Idle/blend_position:y", final_value, 0.125)
		raise_tween.tween_property(animator, "parameters/Walk/CrouchRaised/blend_amount", final_value, 0.125)
		raise_tween.tween_property(animator, "parameters/Walk/WalkRaised/blend_amount", final_value, 0.125)

		if not event.is_pressed():
			var caught: bool = await catch()
			if caught:
				animator.set("parameters/Swing/TimeScale/scale", 0.0)
				set_physics_process(false)
				animals_left -= 1
				$CatchStunTimer.start()
				$Audio/Capture.play()
				var t_finish: float = $CameraPivot.rotation.y
				var catch_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT_IN)
				catch_tween.tween_property($CameraPivot, "rotation:y", t_finish, 2.0).from(t_finish + TAU)

				$AnimalCard.show()
				$AnimalCardShownTime.stop()
				$AnimalCardShownTime.start()

				%AnimalDescriptorCard.set_data(caught_animals.back())
				catch_tween.finished.connect(func() -> void:
					animator.set("parameters/Swing/TimeScale/scale", 1.0))

				set_face_idx(Face.SURPRISED)
				_check_animal_count()
			else:
				set_face_idx(Face.SAD)
	elif event.is_action("crouch") and toggle_crouch:
		if event.is_pressed():
			crouching = not crouching

			var crouch_tween: Tween = create_tween().set_parallel()
			var final_value: float = 1.0 if crouching else 0.0
			crouch_tween.tween_property(animator, "parameters/Idle/blend_position:x", final_value, 0.125)
			crouch_tween.tween_property(animator, "parameters/Walk/Crouch/blend_amount", final_value, 0.125)
	elif event.is_action("crouch"):
		if crouching != event.is_pressed():
			crouching = event.is_pressed()

			var crouch_tween: Tween = create_tween().set_parallel()
			var final_value: float = 1.0 if crouching else 0.0
			crouch_tween.tween_property(animator, "parameters/Idle/blend_position:x", final_value, 0.125)
			crouch_tween.tween_property(animator, "parameters/Walk/Crouch/blend_amount", final_value, 0.125)


func _on_game_settings_continue_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Settings.hide()


func knockback(force: Vector3) -> void:
	if hurt_timer.is_stopped():
		velocity = force + up_direction * JUMP_VELOCITY
	else:
		velocity += force
	hurt_timer.start()
	$Audio/PainBounce.play()
	set_face_idx(Face.OUCH)


func catch() -> bool:
	animator_playback.travel("Swing")
	$Audio/Swing.play()
	%SwingParticles.emitting = true
	catch_anticipate.start()
	await catch_anticipate.timeout

	if not net_hitbox.has_overlapping_bodies():
		return false

	var a_hit: bool = false
	for hit: Node3D in net_hitbox.get_overlapping_bodies():
		
		var clone: GPUParticles3D = null
		var animal: Node3D = hit.get_parent().get_parent()
		if animal.descriptor != null:
			caught_animals.append(animal.descriptor)
			if animal.descriptor.name == "Michael Buble":
				clone = buble_particles.instantiate()
		
		if clone == null:
			clone = catch_particles.instantiate()
		add_sibling(clone)
		clone.global_position = hit.global_position
		clone.emitting = true
		animal.queue_free()
		a_hit = true

	return a_hit


func _on_catch_stun_timer_timeout() -> void:
	set_physics_process(true)


func _on_animal_card_shown_time_timeout() -> void:
	$AnimalCard.hide()


enum Face {
	NEUTRAL,
	SURPRISED,
	SAD,
	OUCH
}

func set_face_idx(idx: Face) -> void:
	eye_material.uv1_offset = Vector3(idx * 0.25, 0, 0)
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		eye_material.uv1_offset = Vector3.ZERO) # reset


func _on_arcade_timer_timeout() -> void:
	# Do all the end game stuff here
	_open_credits()


func _init_credits() -> void:
	var credits_screen: CreditsScreen = $GameOver/CreditsScreen as CreditsScreen
	credits_screen.reset_credits()


func _open_credits(time_left: float = 0) -> void:
	$AnimalCard.hide()
	var game_over_layer: CanvasLayer = $GameOver as CanvasLayer
	var time_layer: CanvasLayer = $Time as CanvasLayer
	var credits_screen: CreditsScreen = $GameOver/CreditsScreen as CreditsScreen

	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	time_layer.hide()
	game_over_layer.show()

	# Assuming timer is stopped early when all animals caught
	credits_screen.set_end_level_stats(caught_animals, time_left)
	credits_screen.start_credits()


func _count_all_animals() -> int:
	var nodes := get_tree().get_nodes_in_group("Bubble Beasties")
	return len(nodes)


func _check_animal_count() -> void:
	if animals_left != 0:
		return

	var time_left: float = arcade_timer.time_left
	arcade_timer.stop()
	_open_credits(time_left)


func _on_game_settings_quit_pressed() -> void:
	var time_left: float = arcade_timer.time_left
	arcade_timer.stop()
	$Settings.hide()
	_open_credits(time_left)
