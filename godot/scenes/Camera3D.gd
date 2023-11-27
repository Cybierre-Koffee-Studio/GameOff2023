class_name FreeLookCamera extends Camera3D

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER


@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _haut = false
var _bas = false
var _gauche = false
var _droite = false

func _input(event):

    if Input.is_action_just_pressed("MoveCamHaut"):
        _haut = event.pressed
    if Input.is_action_just_pressed("MoveCamBas"):
        _bas = event.pressed
    if Input.is_action_just_pressed("MoveCamGauche"):
        _gauche = event.pressed
    if Input.is_action_just_pressed("MoveCamDroite"):
        _droite = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
    _update_movement(delta)

# Updates camera movement
func _update_movement(delta):
    # Computes desired direction from key states
    _direction = Vector3(
        (_droite as float) - (_gauche as float), 
        
        (_bas as float) - (_haut as float),
        0
    )
    
    # Computes the change in velocity due to desired direction and "drag"
    # The "drag" is a constant acceleration on the camera to bring it's velocity to 0
    var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
        + _velocity.normalized() * _deceleration * _vel_multiplier * delta
    
    # Compute modifiers' speed multiplier
    var speed_multi = 1
    
    # Checks if we should bother translating the camera
    if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
        # Sets the velocity to 0 to prevent jittering due to imperfect deceleration
        _velocity = Vector3.ZERO
    else:
        # Clamps speed to stay within maximum value (_vel_multiplier)
        _velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
        _velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
        _velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
    
        translate(_velocity * delta * speed_multi)
