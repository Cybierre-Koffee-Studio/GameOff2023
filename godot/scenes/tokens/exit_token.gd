extends Node3D

signal exit_reached

func _on_area_3d_area_entered(_area):
    emit_signal("exit_reached")
