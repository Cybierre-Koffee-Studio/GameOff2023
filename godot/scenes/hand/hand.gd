extends Node3D
class_name Hand

signal tile_selected

const tile_template_center = preload("res://scenes/tiles/tile_center.tscn")
const tile_template_corner = preload("res://scenes/tiles/tile_corner.tscn")
const tile_template_corridor = preload("res://scenes/tiles/tile_corridor.tscn")
const tile_template_straight = preload("res://scenes/tiles/tile_straight.tscn")

const possible_tiles : Array[PackedScene] = [tile_template_center, tile_template_corner, tile_template_corridor, tile_template_straight]
var current_hand : Array[Tile]  = []

@onready var tile_markers : Array[Node3D] = [$Tile1, $Tile2, $Tile3, $Tile4, $Tile5]

const selected_tile_scale = 2.6
const selected_tile_position_shift = 0.6

# Called when the node enters the scene tree for the first time.
func _ready():
    deal_hand(GlobalVars.hand_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func deal_hand(nb_tiles):
    var tween = create_tween()
    var i = 0
    for t in range(nb_tiles):
        var marker = tile_markers[t]
        var tile = possible_tiles.pick_random().instantiate()
        tile.connect("select_tile", on_select_tile)
        tile.position = Vector3(marker.position.x, marker.position.y, marker.position.z)
        tile.position.z += 30
        tile.scale = Vector3(2,2,2)
        current_hand.append(tile)
        add_child(tile)
        tween.parallel().tween_property(tile, "position:z", tile.position.z - 30, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(i * 0.15)
        i += 1

func on_select_tile(tile):
    tile_selected.emit(tile)
    var tween = create_tween()
    if GlobalVars.selected_tile != null:
        tween.parallel().tween_property(GlobalVars.selected_tile, "scale", Vector3(2, 2, 2), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(GlobalVars.selected_tile, "position:z", GlobalVars.selected_tile.position.z + selected_tile_position_shift, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    GlobalVars.selected_tile = tile
    tween.parallel().tween_property(GlobalVars.selected_tile, "scale", Vector3(selected_tile_scale, selected_tile_scale, selected_tile_scale), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(GlobalVars.selected_tile, "position:z", GlobalVars.selected_tile.position.z - selected_tile_position_shift, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func on_tile_placed(tile):
    GlobalVars.selected_tile.scale = Vector3(1, 1, 1)
    GlobalVars.selected_tile.position.z += selected_tile_position_shift
    GlobalVars.selected_tile = null
    current_hand.erase(tile)
    remove_child(tile)
    GlobalVars.selected_tile = null
    for t in current_hand :
        t.queue_free()
    current_hand = []
    deal_hand(GlobalVars.hand_size)
