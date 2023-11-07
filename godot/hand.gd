extends Node3D
class_name Hand

const tile_template_center = preload("res://tile_center.tscn")
const tile_template_corner = preload("res://tile_corner.tscn")
const tile_template_corridor = preload("res://tile_corridor.tscn")
const tile_template_straight = preload("res://tile_straight.tscn")
const tile_empty = preload("res://tuile.tscn")

const possible_tiles : Array[PackedScene] = [tile_template_center, tile_template_corner, tile_template_corridor, tile_template_straight]

@onready var hand : Array[Node3D] = [$tile1, $tile2, $tile3, $tile4, $tile5]

# Called when the node enters the scene tree for the first time.
func _ready():
	deal_hand(5)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func deal_hand(nb_tiles):
	
	for t in hand:
		var tile = possible_tiles.pick_random().instantiate()
#		var tile = tile_empty.instantiate()
		tile.position = t.position
		add_child(tile)
	pass
