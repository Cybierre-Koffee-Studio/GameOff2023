extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_moving = false

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    if Input.is_action_just_pressed("rotaCamDroite") :
        turn_cam(Vector3(0, -90, 0))
#        rotation_degrees = rotation_degrees + Vector3(0, -90, 0)
        
    if Input.is_action_just_pressed("rotaCamGauche") :
        turn_cam(Vector3(0, 90, 0))
#        rotation_degrees = rotation_degrees + Vector3(0, 90, 0)
    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
#    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if Input.is_action_just_pressed("Avancer") :
        if $RayCastForward.is_colliding() and !is_moving:
            is_moving = true
            move($RayCastForward.get_collider().global_position)
    if Input.is_action_just_pressed("Reculer") :
        if $RayCastBack.is_colliding() and !is_moving:
            is_moving = true
            move($RayCastBack.get_collider().global_position)
    if Input.is_action_just_pressed("AllerADroite") :
        if $RayCastRight.is_colliding() and !is_moving:
            is_moving = true
            move($RayCastRight.get_collider().global_position)
    if Input.is_action_just_pressed("AllerAGauche") :
        if $RayCastLeft.is_colliding() and !is_moving:
            is_moving = true
            move($RayCastLeft.get_collider().global_position)
#    if direction:
#        velocity.x = direction.x * SPEED
#        velocity.z = direction.z * SPEED
#    else:
#        velocity.x = move_toward(velocity.x, 0, SPEED)
#        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

func move(target_pos):
    var tween = get_tree().create_tween()
    tween.tween_property($".", "global_position", target_pos, 0.25)
    await get_tree().create_timer(0.25).timeout
    is_moving = false

func turn_cam(deg):
    var tween = get_tree().create_tween()
    var target_deg = rotation_degrees + deg
    tween.tween_property($".", "rotation_degrees", target_deg, 0.25)
    
