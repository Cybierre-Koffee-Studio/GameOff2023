extends StaticBody3D

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

func _ready():
    pass

func _process(_delta:float):
    pass

func _physics_process(_delta:float):
    pass

func ouvrir_trappe():
    $MeshInstance3D/MeshInstance3D3.visible = true
    $MeshInstance3D/MeshInstance3D2.visible = false
#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

