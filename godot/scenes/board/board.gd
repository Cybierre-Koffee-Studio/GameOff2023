extends Node3D

signal tile_placed

var tileSlotScene = preload("res://scenes/board/tile_slot.tscn")
var keyTokenScene = preload("res://scenes/tokens/key_token.tscn")
var exitTokenScene = preload("res://scenes/tokens/exit_token.tscn")
var GRID_SIZE = 11

const tile_template_center = preload("res://scenes/tiles/tile_center.tscn")
const tile_template_corner = preload("res://scenes/tiles/tile_corner.tscn")
const tile_template_corridor = preload("res://scenes/tiles/tile_corridor.tscn")
const tile_template_straight = preload("res://scenes/tiles/tile_straight.tscn")

const possible_tiles : Array[PackedScene] = [tile_template_center, tile_template_corner, tile_template_corridor, tile_template_straight]

func _ready():
    $Mesh.scale = Vector3(GRID_SIZE, 0.5, GRID_SIZE)
    for i in GRID_SIZE*GRID_SIZE:
        var tileSlot: Node3D = tileSlotScene.instantiate()
        tileSlot.position.x = i/GRID_SIZE - GRID_SIZE/2
        tileSlot.position.z = i%GRID_SIZE - GRID_SIZE/2
        tileSlot.position.y = 0.5
        tileSlot.connect("add_tile", on_add_tile)
        add_child(tileSlot)
    # placement de la tuile clé
    var keyTile = possible_tiles.pick_random().instantiate()
    keyTile.position = Vector3(randi_range(-GRID_SIZE/2, GRID_SIZE/2-1), 0.5, randi_range(-GRID_SIZE/2, GRID_SIZE/2-1))
    add_child(keyTile)
    var keyToken = keyTokenScene.instantiate()
    keyToken.position = Vector3(keyTile.position.x, keyTile.position.y + 0.1, keyTile.position.z)
    add_child(keyToken)
    # placement de la tuile sortie
    var exitTile = possible_tiles.pick_random().instantiate()
    exitTile.position = Vector3(randi_range(-GRID_SIZE/2, GRID_SIZE/2-1), 0.5, randi_range(-GRID_SIZE/2, GRID_SIZE/2-1))
    add_child(exitTile)
    var exitToken = exitTokenScene.instantiate()
    exitToken.position = Vector3(exitTile.position.x, exitTile.position.y + 0.1, exitTile.position.z)
    add_child(exitToken)
    # placement de la tuile de départ
    var startTile = possible_tiles.pick_random().instantiate()
    startTile.position = Vector3(0, 0.5, 0)
    add_child(startTile)

func _process(_delta):
    pass

func _unhandled_input(_event):
    if Input.is_action_just_pressed("rotate_tile") && GlobalVars.selected_tile && GlobalVars.selected_tile_copy != null && GlobalVars.selected_tile.can_rotate && GlobalVars.selected_tile_copy.can_rotate:
        rotate_tile()

func on_add_tile(src):
    var tuile = GlobalVars.selected_tile_copy
    remove_child(GlobalVars.selected_tile_copy)
    GlobalVars.selected_tile_copy = null
    emit_signal("tile_placed", tuile)
    tuile.position = src.position
    tuile.position.y = 50
    add_child(tuile)
    var tween = create_tween()
    tween.tween_property(tuile, "position:y", 0.5, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_callback(src.queue_free)
    tip(tuile.position.x*0.8)

func tip(angle):
    var tween = create_tween()
    tween.tween_property(self, "rotation_degrees:z", rotation_degrees.z - angle, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6)
    
func on_tile_selected(tile):
    GlobalVars.selected_tile_rotation = tile.rotation.y
    if GlobalVars.selected_tile_copy != null:
        remove_child(GlobalVars.selected_tile_copy)
    GlobalVars.selected_tile_copy = tile.duplicate()
    GlobalVars.selected_tile_copy.rotation = GlobalVars.selected_tile.rotation
    GlobalVars.selected_tile_copy.scale = Vector3(1,1,1)
    GlobalVars.selected_tile_copy.visible = false
    add_child(GlobalVars.selected_tile_copy)
    
func rotate_tile():
    GlobalVars.selected_tile_copy.can_rotate = false
    GlobalVars.selected_tile.can_rotate = false
    GlobalVars.selected_tile_rotation += deg_to_rad(90.0)
    var tween_selected_tile = create_tween()
    tween_selected_tile.tween_property(GlobalVars.selected_tile, "rotation:y", GlobalVars.selected_tile_rotation, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
    var tween_selected_tile_copy = create_tween()
    tween_selected_tile_copy.tween_property(GlobalVars.selected_tile_copy, "rotation:y", GlobalVars.selected_tile_rotation, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
    GlobalVars.selected_tile_copy.can_rotate = true
    GlobalVars.selected_tile.can_rotate = true
