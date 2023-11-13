extends Node3D
class_name Hand

signal tile_selected

const tile_scene = preload("res://scenes/tiles/tile.tscn")

const possible_tiles : Array[Tile.TYPE] = [Tile.TYPE.CENTER, Tile.TYPE.CORNER, Tile.TYPE.CORRIDOR, Tile.TYPE.STRAIGHT]
var current_hand : Array[Tile]  = []

const rotations = [0, 90, 180, 270]

@onready var tile_markers : Array[Node3D] = [$Tile1, $Tile2, $Tile3, $Tile4, $Tile5]

const selected_tile_scale = 2.6
const selected_tile_position_shift = 0.6

# Called when the node enters the scene tree for the first time.
func _ready():
    deal_hand(GlobalVars.hand_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func deal_hand(nb_tiles):
    var tween = create_tween()
    var i = 0
    for t in range(nb_tiles):
        var marker = tile_markers[t]
        var tile = tile_scene.instantiate()
        tile.init(possible_tiles.pick_random())
        tile.connect("select_tile", on_select_tile)
        tile.position = Vector3(marker.position.x, marker.position.y, marker.position.z)
        tile.position.z += 30
        tile.rotation.y = deg_to_rad(rotations.pick_random())
        tile.scale = Vector3(2,2,2)
        current_hand.append(tile)
        add_child(tile)
        tween.parallel().tween_property(tile, "position:z", tile.position.z - 30, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(i * 0.15)
        i += 1

func on_select_tile(tile):
    if GlobalVars.selected_tile != null && tile.can_move:
        var tween = create_tween()
        tween.parallel().tween_property(GlobalVars.selected_tile, "scale", Vector3(2, 2, 2), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(GlobalVars.selected_tile, "position:z", GlobalVars.selected_tile.position.z + selected_tile_position_shift, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        GlobalVars.selected_tile.can_move = true
    GlobalVars.selected_tile = tile
    if tile.can_move :
        var tween = create_tween()
        tween.parallel().tween_property(GlobalVars.selected_tile, "scale", Vector3(selected_tile_scale, selected_tile_scale, selected_tile_scale), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(GlobalVars.selected_tile, "position:z", GlobalVars.selected_tile.position.z - selected_tile_position_shift, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tile.can_move = false
    tile_selected.emit(tile)

func on_tile_placed(tile):
    GlobalVars.selected_tile.scale = Vector3(1, 1, 1)
    GlobalVars.selected_tile.position.z += selected_tile_position_shift
    GlobalVars.selected_tile = null
    tile.can_rotate = false
    current_hand.erase(tile)
    GlobalVars.selected_tile = null
    for t in current_hand :
        t.queue_free()
    current_hand = []
    deal_hand(GlobalVars.hand_size)
