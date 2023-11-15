extends Node

var selected_tile : Tile
var selected_tile_rotation
var hand_size
var got_key
var started

func _init():
    started = false
    hand_size = 5
    selected_tile = null
    selected_tile_rotation = 0
    got_key = false
