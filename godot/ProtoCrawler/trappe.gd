extends StaticBody3D

const game_end_scene = preload("res://ProtoCrawler/game_end_hud.tscn")

var trappe_ouverte = false

#------------------------------------------
# Signaux
#------------------------------------------
signal game_end

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func ouvrir_trappe():
    trappe_ouverte = true
    $MeshInstance3D/MeshInstance3D3.visible = true
    $MeshInstance3D/MeshInstance3D2.visible = false
#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_area_3d_body_entered(_body):
    if trappe_ouverte :
        var lecran = game_end_scene.instantiate()
        get_parent().add_child(lecran)
        GlobalVars.can_player_move = false
        emit_signal("game_end")

func look_at_player(posi):
    var target_pos = Vector3(posi.x, global_transform.origin.y+0.01 , posi.z)
    if position.direction_to(target_pos) != Vector3.UP:
        look_at(target_pos, Vector3.UP, true)
