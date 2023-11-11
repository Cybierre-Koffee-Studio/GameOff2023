extends Node3D

signal tile_placed

const GRID_SIZE = 11
# taille de la zone périphérique où les tuiles clé et sortie pourront être placées
const PERIPHERAL_ZONE_WIDTH = max(floor(GRID_SIZE / 4), 1)

const tileSlotScene = preload("res://scenes/board/tile_slot.tscn")
const keyTokenScene = preload("res://scenes/tokens/key_token.tscn")
const exitTokenScene = preload("res://scenes/tokens/exit_token.tscn")

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
        
    # placement de la tuile de départ
    var startTile = tile_template_center.instantiate()
    startTile.position = Vector3(0, 0.5, 0)
    add_child(startTile)
    
    # on détermine les limites des zones périphériques du plateau
    # pour chaque zone le tableau contient dans l'ordre :
    #   la limite en haut à gauche de la zone
    #   la limite en bas à droite de la zone
    const zones = [
        # 0 : zone du haut
        [Vector2(0, 0), Vector2(GRID_SIZE-1, PERIPHERAL_ZONE_WIDTH-1)],
        # 1 : à droite
        [Vector2(GRID_SIZE-PERIPHERAL_ZONE_WIDTH, 0), Vector2(GRID_SIZE-1, GRID_SIZE-1)],
        # 2 : en bas
        [Vector2(0, GRID_SIZE-PERIPHERAL_ZONE_WIDTH), Vector2(GRID_SIZE-1, GRID_SIZE-1)],
        # 4 : à gauche
        [Vector2(0, 0), Vector2(PERIPHERAL_ZONE_WIDTH-1, GRID_SIZE-1)]
    ]

    # on positionne les tuiles clé et sortie :
    #   si randomPosition=0 : clé en haut, sortie en bas
    #   si randomPosition=1 : clé à droite, sortie à gauche
    #   si randomPosition=2 : clé en bas, sortie en haut
    #   si randomPosition=3 : clé à gauche, sortie à droite
    var randomPosition = randi_range(0, 3)
    var keyTileZone = randomPosition
    var exitTileZone = (randomPosition + 2) % 4
    
    # placement de la tuile clé
    var keyTile = possible_tiles.pick_random().instantiate()
    keyTile.position = Vector3(
        randi_range(zones[keyTileZone][0].x - GRID_SIZE/2, zones[keyTileZone][1].x - GRID_SIZE/2),
        0.5,
        randi_range(zones[keyTileZone][0].y - GRID_SIZE/2, zones[keyTileZone][1].y - GRID_SIZE/2)
    )
    add_child(keyTile)
    # avec le marqueur de clé dessus
    var keyToken = keyTokenScene.instantiate()
    keyToken.position = Vector3(keyTile.position.x, keyTile.position.y + 0.1, keyTile.position.z)
    add_child(keyToken)
    
    # placement de la tuile sortie
    var exitTile = possible_tiles.pick_random().instantiate()
    exitTile.position = Vector3(
        randi_range(zones[exitTileZone][0].x - GRID_SIZE/2, zones[exitTileZone][1].x - GRID_SIZE/2),
        0.5,
        randi_range(zones[exitTileZone][0].y - GRID_SIZE/2, zones[exitTileZone][1].y - GRID_SIZE/2)
    )
    add_child(exitTile)
    # avec le marqueur de sortie dessus
    var exitToken = exitTokenScene.instantiate()
    exitToken.position = Vector3(exitTile.position.x, exitTile.position.y + 0.1, exitTile.position.z)
    add_child(exitToken)

#func _unhandled_input(_event):
#    if Input.is_action_just_pressed("rotate_tile") && GlobalVars.selected_tile && GlobalVars.selected_tile_copy != null && GlobalVars.selected_tile.can_rotate && GlobalVars.selected_tile_copy.can_rotate:
#        rotate_tile()

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
