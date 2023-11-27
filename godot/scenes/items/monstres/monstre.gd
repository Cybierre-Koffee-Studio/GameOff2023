extends Item

var cliquable = false
var niveau = 0

func _ready():
    pass
#    niveau = randi_range(1,3)
#    match niveau :
#        1:
#            var chovsouris = preload("res://ProtoCrawler/enemy_model/chovsouris.tscn").instantiate()
#            add_child(chovsouris)
#        2:
#            var mimic = preload("res://ProtoCrawler/enemy_model/mimic.tscn").instantiate()
#            add_child(mimic)
#        3:
#            var fantom = preload("res://ProtoCrawler/enemy_model/fantom.tscn").instantiate()
#            add_child(fantom)

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
    niveau = randi_range(1,3)
    match niveau :
        1:
            var chovsouris = preload("res://ProtoCrawler/enemy_model/chovsouris.tscn").instantiate()
            add_child(chovsouris)
#            chovsouris.look_at(Vector3(0,0,0))
        2:
            var mimic = preload("res://ProtoCrawler/enemy_model/mimic.tscn").instantiate()
            add_child(mimic)
#            mimic.look_at(Vector3(0,0,0))
        3:
            var fantom = preload("res://ProtoCrawler/enemy_model/fantom.tscn").instantiate()
            add_child(fantom)
#            fantom.look_at(Vector3(0,0,0))
