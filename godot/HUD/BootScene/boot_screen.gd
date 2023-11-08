extends Control
class_name BootScreen

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

@onready var _jingle_player:AudioStreamPlayer = $JinglePlayer

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
    _jingle_player.play()
    _jingle_player.finished.connect(_on_load_main_menu_timer_timeout)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_load_main_menu_timer_timeout() -> void:
    get_tree().change_scene_to_packed(preload("res://HUD/MenuScreen/menu_screen.tscn"))
