extends StaticBody3D

var trappe_ouverte = false
#------------------------------------------
# Signaux
#------------------------------------------

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
        GlobalVars.can_player_move = false
        get_parent().get_parent().next_level()
