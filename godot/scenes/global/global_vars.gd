extends Node

var selected_tile : Tile
var selected_tile_rotation
var hand_size
var started = false
var fin_reliee = false
var key_reliee = false
var got_key
var at_exit
var started
var debug
var reroll_number

func _init():
    started = false
    hand_size = 5
    selected_tile = null
    selected_tile_rotation = 0
    got_key = false
    at_exit = false
    debug = false
    reroll_number = 0
    fin_reliee = false
    key_reliee = false
    started = false
