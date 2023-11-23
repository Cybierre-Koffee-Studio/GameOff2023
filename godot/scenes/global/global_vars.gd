extends Node

signal heal_player
signal player_power_up
signal blesser_joueur

var selected_tile : Tile
var selected_tile_rotation
var hand_size
var started = false
var fin_reliee = false
var key_reliee = false
var got_key
var at_exit
var debug
var reroll_number
var can_player_move = false

var player_power = 0

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
    can_player_move = false

func soigner_joueur():
    emit_signal("heal_player")

func power_up(valeur):
    player_power += valeur
    emit_signal("player_power_up", player_power)

func blesser_le_joueur():
    emit_signal("blesser_joueur")
