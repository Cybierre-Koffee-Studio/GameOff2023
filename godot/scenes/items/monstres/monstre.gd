extends ClickableItem


var niveau = 0          

func execute_action():
    if GlobalVars.player_power < niveau :
        GlobalVars.blesser_le_joueur()
    else :
        GlobalVars.power_up(-1)

    queue_free()
    GlobalVars.add_score(niveau)

func activate():
    $Area3D.input_ray_pickable = true
    niveau = randi_range(1,3)
    match niveau :
        1:
            var chovsouris = preload("res://ProtoCrawler/enemy_model/chovsouris.tscn").instantiate()
            add_child(chovsouris)
        2:
            var mimic = preload("res://ProtoCrawler/enemy_model/mimic.tscn").instantiate()
            add_child(mimic)
        3:
            var fantom = preload("res://ProtoCrawler/enemy_model/fantom.tscn").instantiate()
            add_child(fantom)
