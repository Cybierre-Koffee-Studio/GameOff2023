extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var can_move = true
var can_rotate = true

func _physics_process(_delta):
    if !GlobalVars.can_player_move : return
    move_and_slide()

func _unhandled_key_input(event):
    if event.is_action_pressed("rotaCamDroite"):
        turn_cam(Vector3(0, -90, 0))
    if event.is_action_pressed("rotaCamGauche"):
        turn_cam(Vector3(0, 90, 0))
    if event.is_action_pressed("Avancer"):
        if $RayCastForward.is_colliding() && !$RayCastForwardMonster.is_colliding():
            move($RayCastForward.get_collider().global_position)
    if event.is_action_pressed("Reculer"):
        if $RayCastBack.is_colliding() && !$RayCastBackMonster.is_colliding():
            move($RayCastBack.get_collider().global_position)
    if event.is_action_pressed("AllerADroite"):
        if $RayCastRight.is_colliding() && !$RayCastRightMonster.is_colliding():
            move($RayCastRight.get_collider().global_position)
    if event.is_action_pressed("AllerAGauche"):
        if $RayCastLeft.is_colliding() && !$RayCastLeftMonster.is_colliding():
            move($RayCastLeft.get_collider().global_position)
            

func move(target_pos):
    if can_move:
        can_move = false
        var tween = get_tree().create_tween()
        tween.tween_property($".", "global_position", target_pos, 0.25)
        await get_tree().create_timer(0.25).timeout
    can_move = true

func turn_cam(deg):
    if can_rotate:
        can_rotate = false
        var tween = get_tree().create_tween()
        var target_deg = rotation_degrees + deg
        tween.tween_property($".", "rotation_degrees", target_deg, 0.25)
        await tween.finished
    can_rotate = true

func set_cam_current():
    GlobalVars.can_player_move = true
    $Camera3D.current = true
