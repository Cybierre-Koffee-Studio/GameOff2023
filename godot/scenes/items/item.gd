extends Node3D
class_name Item

func place_on_tile(tile):
    position = Vector3(tile.position.x, tile.position.y + 0.1, tile.position.z)

func on_placement():
    print("Item placed, doing placement effect")

func on_pickup():
    print("Item picked up, doing pickup effect")
