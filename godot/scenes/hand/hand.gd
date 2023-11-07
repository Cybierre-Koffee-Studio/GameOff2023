extends Node3D
class_name Hand

const tile_template_center = preload("res://scenes/tiles/tile_center.tscn")
const tile_template_corner = preload("res://scenes/tiles/tile_corner.tscn")
const tile_template_corridor = preload("res://scenes/tiles/tile_corridor.tscn")
const tile_template_straight = preload("res://scenes/tiles/tile_straight.tscn")

const possible_tiles : Array[PackedScene] = [tile_template_center, tile_template_corner, tile_template_corridor, tile_template_straight]
var current_hand : Array[Tile]  = []

@onready var tile_markers : Array[Node3D] = [$Tile1, $Tile2, $Tile3, $Tile4, $Tile5]

# Called when the node enters the scene tree for the first time.
func _ready():
    deal_hand(GlobalVars.hand_size)
    
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func deal_hand(nb_tiles):
    for t in range(nb_tiles):
        var tile = possible_tiles.pick_random().instantiate()
        tile.connect("select_tile", on_select_tile)
        #var tile = tile_empty.instantiate()
        tile.position = tile_markers[t].position
        current_hand.append(tile)
        add_child(tile)
    pass

func on_select_tile(tile):
    GlobalVars.selected_tile = tile
    pass
    
func on_tile_placed(tile):
    current_hand.erase(tile)
    remove_child(tile)
    for t in current_hand :
        current_hand.erase(t)
        t.queue_free()
    deal_hand(GlobalVars.hand_size)
