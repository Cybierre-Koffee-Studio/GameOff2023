extends Node

var selected_tile : Tile
var selected_tile_rotation
var hand_size

func _init():
    hand_size = 5
    selected_tile = null
    selected_tile_rotation = 0
