extends Node3D

signal exit_reached

func _on_area_3d_area_entered(_area):
    if (_area.get_parent().is_in_group("player")):
        emit_signal("exit_reached")
