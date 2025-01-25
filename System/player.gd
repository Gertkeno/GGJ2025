extends CharacterBody3D


const SPEED: float = 5.0
const CROUCH_SPEED: float = 3.5
const GROUND_ACCELERATION: float = 40.0
const AIR_ACCELERATION: float = 10.0
const JUMP_VELOCITY: float = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var vertical_velocity := velocity.project(up_direction)
	var horizontal_velocity := velocity - vertical_velocity

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = JUMP_VELOCITY * up_direction

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := transform.basis.orthonormalized() * Vector3(input_dir.x, 0, input_dir.y)

	var accel: float = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var speed: float = CROUCH_SPEED if Input.is_action_just_pressed("crouch") else SPEED
	horizontal_velocity = horizontal_velocity.move_toward(direction*speed, accel*delta)
	velocity = horizontal_velocity + vertical_velocity

	move_and_slide()


var screen_size: Vector2
func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.screen_relative.x / screen_size.x * PI)
			$CameraPivot.rotate_x(-event.screen_relative.y / screen_size.y * PI)
	elif event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
