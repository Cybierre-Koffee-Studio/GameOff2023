extends Node

signal heal_player
signal player_power_up
signal blesser_joueur
signal score_changed
signal cave_level_changed
signal reroll_count_changed

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
var score = 0
var cave_level = 1
var player_power = 0

func _init():
    score = 0
    cave_level = 1
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

func add_score(value):
    score += value
    emit_signal("score_changed")

func level_ended():
    cave_level += 1
    emit_signal("cave_level_changed")

func change_reroll(value):
    reroll_number += value
    emit_signal("reroll_count_changed")
