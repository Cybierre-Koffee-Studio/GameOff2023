extends Node3D
class_name Item

func place_on_tile(tile):
    position = Vector3(tile.position.x, tile.position.y + 0.1, tile.position.z)

func on_tile_placed(_tile):
    pass
#    print("Item placed, doing placement effect")
