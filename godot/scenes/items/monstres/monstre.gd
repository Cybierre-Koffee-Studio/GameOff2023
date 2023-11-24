extends Item

var cliquable = false
var niveau = 0

func _ready():
    niveau = randi_range(1,3)

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and cliquable :
            if GlobalVars.player_power < niveau :
                GlobalVars.blesser_le_joueur()
            queue_free()
            GlobalVars.add_score(niveau)

func _on_area_3d_mouse_entered():
    cliquable = true

func _on_area_3d_mouse_exited():
    cliquable = false

func activate():
    $Area3D.input_ray_pickable = true
