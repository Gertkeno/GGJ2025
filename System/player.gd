extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const CROUCH_SPEED: float = 3.5
const GROUND_ACCELERATION: float = 40.0
const AIR_ACCELERATION: float = 5.0
const JUMP_VELOCITY: float = 5.5

#region control options
static var camera_sensitivity: float = 1.0
static var y_invert: float = 1.0
#endregion

@export var catch_particles: PackedScene

@onready var hurt_timer: Timer = $HurtTimer
@onready var net_hitbox: Area3D = $NetHitbox
@onready var animator: AnimationTree = $AnimationTree
@onready var arcade_timer: Timer = $ArcadeTimer
@onready var time_display: ArcadeTimer = $Time
@export var player_mesh: MeshInstance3D
var eye_material: StandardMaterial3D
var crouching: bool = false # for enemy detection


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
		vertical_velocity = JUMP_VELOCITY * up_direction

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = $CameraPivot.global_basis.orthonormalized() * Vector3(input_dir.x, 0, input_dir.y)

	if hurt_timer.is_stopped():
		var accel: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		var speed: float = CROUCH_SPEED if Input.is_action_pressed("crouch") else SPEED
		horizontal_velocity = horizontal_velocity.move_toward(direction*speed, accel*delta)

		if direction:
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


func _process(delta: float) -> void:
	var controller_direction: Vector2 = Input.get_vector("turn_left", "turn_right", "turn_up", "turn_down")
	if controller_direction:
		var camera_move: Vector2 = controller_direction * PI * delta * camera_sensitivity
		$CameraPivot.rotate_y(-camera_move.x)
		$CameraPivot/SpringArm3D.rotate_x(camera_move.y * y_invert)
		$CameraPivot/SpringArm3D.rotation.x = clampf($CameraPivot/SpringArm3D.rotation.x, -CAMERA_ANGLE_MAX, CAMERA_ANGLE_MAX)
	animator.set("parameters/Walk/WalkSpeed/scale", velocity.length() / SPEED)
	time_display.set_time(arcade_timer.time_left)


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

	if event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Settings.show()
		get_tree().paused = true
	elif event.is_action_pressed("catch") and hurt_timer.is_stopped():
		if catch():
			animator.active = false
			set_physics_process(false)
			$CatchStunTimer.start()
			var t_finish: float = $CameraPivot.rotation.y
			var catch_tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			catch_tween.tween_property($CameraPivot, "rotation:y", t_finish, 1.5).from(t_finish + PI)
			set_face_idx(1)
		else:
			set_face_idx(2)
	elif event.is_action("crouch"):
		if crouching != event.is_pressed():
			crouching = event.is_pressed()
			var crouch_tween: Tween = create_tween()
			var final_value: float = 1.0 if crouching else 0.0
			crouch_tween.tween_property(animator, "parameters/Idle/blend_position", final_value, 0.125)


func _on_game_settings_continue_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Settings.hide()


func knockback(force: Vector3) -> void:
	if hurt_timer.is_stopped():
		velocity = force + up_direction * JUMP_VELOCITY
	else:
		velocity += force
	hurt_timer.start()
	set_face_idx(3)


func catch() -> bool:
	if not net_hitbox.has_overlapping_bodies():
		return false

	var a_hit: bool = false
	for hit in net_hitbox.get_overlapping_bodies():
		var clone: GPUParticles3D = catch_particles.instantiate()
		clone.global_position = hit.global_position
		add_sibling(clone)
		clone.emitting = true
		hit.get_parent().get_parent().queue_free()
		a_hit = true

	return a_hit


func _on_catch_stun_timer_timeout() -> void:
	set_physics_process(true)
	animator.active = true


# 0 neutral
# 1 surprised
# 2 sleepy
# 3 ouch
func set_face_idx(idx: int) -> void:
	eye_material.uv1_offset = Vector3(idx * 0.25, 0, 0)
