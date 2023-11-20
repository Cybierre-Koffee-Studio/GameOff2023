extends Node3D
class_name Item

@export var hitbox: Area3D

func place_on_tile(tile):
    position = Vector3(tile.position.x, tile.position.y + 0.1, tile.position.z)

func on_tile_placed(_tile):
    print("Item placed, doing placement effect")

func on_pickup(_area):
    print("Item picked up, doing pickup effect")

func _get_configuration_warning() -> String:
    if hitbox == null:
        return "An Area3D is required"
    return ""
