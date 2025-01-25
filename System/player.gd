extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const CROUCH_SPEED: float = 3.5
const GROUND_ACCELERATION: float = 40.0
const AIR_ACCELERATION: float = 5.0
const JUMP_VELOCITY: float = 4.5

#region control options
static var camera_sensitivity: float = 1.0
static var y_invert: float = 1.0
#endregion


@onready var hurt_timer: Timer = $HurtTimer
@onready var net_hitbox: Area3D = $NetHitbox


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
		if last_collision.get_collider().collision_layer == 1:
			set_meta("last_jump", position)
		vertical_velocity = JUMP_VELOCITY * up_direction

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := transform.basis.orthonormalized() * Vector3(input_dir.x, 0, input_dir.y)

	if hurt_timer.is_stopped():
		var accel: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		var speed: float = CROUCH_SPEED if Input.is_action_pressed("crouch") else SPEED
		horizontal_velocity = horizontal_velocity.move_toward(direction*speed, accel*delta)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, AIR_ACCELERATION*delta)
		
	velocity = horizontal_velocity + vertical_velocity

	move_and_slide()


var screen_size: Vector2
func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()


func _process(delta: float) -> void:
	var controller_direction: Vector2 = Input.get_vector("turn_left", "turn_right", "turn_up", "turn_down")
	if controller_direction:
		var camera_move: Vector2 = controller_direction * PI * delta * camera_sensitivity
		rotate_y(-camera_move.x)
		$CameraPivot.rotate_x(camera_move.y * y_invert)
		$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, -CAMERA_ANGLE_MAX, CAMERA_ANGLE_MAX)


const CAMERA_ANGLE_MAX = deg_to_rad(70)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var camera_move: Vector2 = event.screen_relative / screen_size * -PI * camera_sensitivity

			# TODO: rotate camera around player model
			rotate_y(camera_move.x)
			$CameraPivot.rotate_x(camera_move.y * y_invert)
			$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, -CAMERA_ANGLE_MAX, CAMERA_ANGLE_MAX)
	elif event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Settings.show()
		get_tree().paused = true
	elif event.is_action_pressed("catch"):
		if catch():
			pass


func _on_game_settings_continue_pressed() -> void:
	$Settings.hide()


func knockback(force: Vector3) -> void:
	if hurt_timer.is_stopped():
		velocity = force + up_direction * JUMP_VELOCITY
	else:
		velocity += force
	hurt_timer.start()


func catch() -> bool:
	if net_hitbox.has_overlapping_bodies():
		var a_hit: bool = false
		for hit in net_hitbox.get_overlapping_bodies():
			print(hit)
		return a_hit
	else:
		print("No catch! You fail!")
	return false
