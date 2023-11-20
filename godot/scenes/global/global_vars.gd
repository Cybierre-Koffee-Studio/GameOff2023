extends Node

var selected_tile : Tile
var selected_tile_rotation
var hand_size
var started = false
var fin_reliee = false
var key_reliee = false

func _init():
    hand_size = 5
    selected_tile = null
    selected_tile_rotation = 0
    fin_reliee = false
    key_reliee = false
    started = false
