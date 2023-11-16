extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_moving = false
var cam_is_rotating = false

func _physics_process(delta):

    if Input.is_action_just_pressed("rotaCamDroite") and !cam_is_rotating:
        cam_is_rotating = true
        turn_cam(Vector3(0, -90, 0))
    if Input.is_action_just_pressed("rotaCamGauche") and !cam_is_rotating:
        cam_is_rotating = true
        turn_cam(Vector3(0, 90, 0))
    if Input.is_action_just_pressed("changement_gameplay") :
        $Camera3D.current = true
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
    await get_tree().create_timer(0.25).timeout
    cam_is_rotating = false
    
