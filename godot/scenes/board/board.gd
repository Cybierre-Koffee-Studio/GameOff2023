extends Node3D

signal tile_placed

const GRID_SIZE = 11
# taille de la zone périphérique où les tuiles clé et sortie pourront être placées
const PERIPHERAL_ZONE_WIDTH = max(floor(GRID_SIZE / 4), 1)

const tileSlotScene = preload("res://scenes/board/tile_slot.tscn")
const keyTokenScene = preload("res://scenes/tokens/key_token.tscn")
const exitTokenScene = preload("res://scenes/tokens/exit_token.tscn")

const tile_scene = preload("res://scenes/tiles/tile.tscn")

const possible_tiles : Array[Tile.TYPE] = [Tile.TYPE.CENTER, Tile.TYPE.CORNER, Tile.TYPE.CORRIDOR, Tile.TYPE.STRAIGHT]

const rotations = [0, 90, 180, 270]

# dans GRID_MAP on range des infos sur les emplacements du plateau utiles pour calculer les contraintes de placement
# le premier point d'entrée est la colonne où est positionné l'emplacement (position en x dans la grille)
var GRID_MAP = [
    # le deuxième point d'entrée est la ligne où est positionné l'emplacement (position en y dans la grille)
    # [
        # à l'intérieur on va ranger un tableau contenant les informations sur l'emplacement et ses voisins
        # [
            #  0 = le tile_slot de l'emplacement
            #  1 = binaire qui représente s'il y a des bords de tuiles ouverts à côté de l'emplacement (0 = non, 1 = oui), par exemple pour un emplacement qui a seulement une tuile placée à sa droite ayant un bord ouvert sur la gauche : 0b0100
            #  2 = binaire qui représente s'il y a des bords de tuiles murés à côté de l'emplacement (0 = non, 1 = oui), par exemple pour un emplacement qui a un mur sur sa droite et un mur sur sa gauche : 0b0101
        # ]
    # ]
]

func _ready():
    $Mesh.scale = Vector3(GRID_SIZE, 0.5, GRID_SIZE)
    GRID_MAP.resize(GRID_SIZE)
    for i in GRID_SIZE*GRID_SIZE:
        var tileSlot: Node3D = tileSlotScene.instantiate()
        var x = i/GRID_SIZE
        var y = i%GRID_SIZE
        tileSlot.position.x = x - GRID_SIZE/2
        tileSlot.position.z = y - GRID_SIZE/2
        tileSlot.position.y = 0.5
        tileSlot.connect("add_tile", on_add_tile)
        add_child(tileSlot)
        if GRID_MAP[x] == null:
            GRID_MAP[x] = []
            GRID_MAP[x].resize(GRID_SIZE)
        # pour chaque emplacement du plateau on intialise les infos de GRID_MAP
        GRID_MAP[x][y] = [
            # slot
            tileSlot,
            # aucune ouverture voisine
            0b0000,
            # aucun mur voisin
            0b0000
        ]
        
    # placement de la tuile de départ
    var startTile = tile_scene.instantiate()
    startTile.init(Tile.TYPE.CENTER)
    startTile.position = Vector3(0, 0.5, 0)
    map_tile(GRID_SIZE/2, GRID_SIZE/2, [0b1111,0b0000])
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
    var keyTile = tile_scene.instantiate()
    var keyTileX = randi_range(zones[keyTileZone][0].x, zones[keyTileZone][1].x)
    var keyTileY = randi_range(zones[keyTileZone][0].y, zones[keyTileZone][1].y)
    keyTile.init(possible_tiles.pick_random())
    keyTile.position = Vector3(
        keyTileX - GRID_SIZE/2,
        0.5,
        keyTileY - GRID_SIZE/2
    )
    var keyTileRotation = rotations.pick_random()
    keyTile.rotation.y = deg_to_rad(keyTileRotation)
    add_child(keyTile)
    map_tile(keyTileX, keyTileY, keyTile.get_tile_data())
    # avec le marqueur de clé dessus
    var keyToken = keyTokenScene.instantiate()
    keyToken.position = Vector3(keyTile.position.x, keyTile.position.y + 0.1, keyTile.position.z)
    add_child(keyToken)
    
    # placement de la tuile sortie
    var exitTile = tile_scene.instantiate()
    var exitTileX = randi_range(zones[exitTileZone][0].x , zones[exitTileZone][1].x)
    var exitTileY = randi_range(zones[exitTileZone][0].y, zones[exitTileZone][1].y)
    exitTile.init(possible_tiles.pick_random())
    exitTile.position = Vector3(
        exitTileX - GRID_SIZE/2,
        0.5,
        exitTileY - GRID_SIZE/2
    )
    var exitTileRotation = rotations.pick_random()
    exitTile.rotation.y = deg_to_rad(exitTileRotation)
    add_child(exitTile)
    map_tile(exitTileX, exitTileY, exitTile.get_tile_data())
    # avec le marqueur de sortie dessus
    var exitToken = exitTokenScene.instantiate()
    exitToken.position = Vector3(exitTile.position.x, exitTile.position.y + 0.1, exitTile.position.z)
    add_child(exitToken)
    
func map_tile(x, y, tileData):
    GRID_MAP[x][y][0] = null
    if y > 0:
        # modification des infos de l'emplacement en haut de la tuile posée
        # ouvertures
        GRID_MAP[x][y-1][1] = GRID_MAP[x][y-1][1] | ((tileData[0] & 0b1000) >> 2)
        # murs
        GRID_MAP[x][y-1][2] = GRID_MAP[x][y-1][2] | ((tileData[1] & 0b1000) >> 2)
        
    if x < GRID_SIZE - 1:
        # modification des infos de l'emplacement à droite de la tuile posée
        # ouvertures
        GRID_MAP[x+1][y][1] = GRID_MAP[x+1][y][1] | ((tileData[0] & 0b0100) >> 2)
        # murs
        GRID_MAP[x+1][y][2] = GRID_MAP[x+1][y][2] | ((tileData[1] & 0b0100) >> 2)
    
    if y < GRID_SIZE - 1:
        # modification des infos de l'emplacement en haut de la tuile posée
        # ouvertures
        GRID_MAP[x][y+1][1] = GRID_MAP[x][y+1][1] | ((tileData[0] & 0b0010) << 2)
        # murs
        GRID_MAP[x][y+1][2] = GRID_MAP[x][y+1][2] | ((tileData[1] & 0b0010) << 2)
        
    if x > 0:
        # modification des infos de l'emplacement à gauche de la tuile posée
        # ouvertures
        GRID_MAP[x-1][y][1] = GRID_MAP[x-1][y][1] | ((tileData[0] & 0b0001) << 2)
        # murs
        GRID_MAP[x-1][y][2] = GRID_MAP[x-1][y][2] | ((tileData[1] & 0b0001) << 2)

#func _unhandled_input(_event):
#    if Input.is_action_just_pressed("rotate_tile") && GlobalVars.selected_tile && GlobalVars.selected_tile_copy != null && GlobalVars.selected_tile.can_rotate && GlobalVars.selected_tile_copy.can_rotate:
#        rotate_tile()
        
func slot_compatible(x, y, tile):
    var tile_data = tile.get_tile_data()
    return GRID_MAP[x][y][1] | GRID_MAP[x][y][2] > 0 && !(GRID_MAP[x][y][2] & tile_data[0]) && !(GRID_MAP[x][y][1] & tile_data[1])

func on_add_tile(src):
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            var slot = GRID_MAP[x][y][0]
            if slot != null:
                slot.set_unavailable()
    var tile = GlobalVars.selected_tile_copy
    remove_child(GlobalVars.selected_tile_copy)
    GlobalVars.selected_tile_copy = null
    emit_signal("tile_placed", tile)
    tile.position = src.position
    tile.position.y = 50
    add_child(tile)
    map_tile(tile.position.x + GRID_SIZE/2, tile.position.z + GRID_SIZE/2, tile.get_tile_data())
    var tween = create_tween()
    tween.tween_property(tile, "position:y", 0.5, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_callback(src.queue_free)
    tip(tile.position.x*0.8)

func tip(angle):
    var tween = create_tween()
    tween.tween_property(self, "rotation_degrees:z", rotation_degrees.z - angle, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6)
    
func on_tile_selected(tile):
    GlobalVars.selected_tile_rotation = tile.rotation.y
    if GlobalVars.selected_tile_copy != null:
        remove_child(GlobalVars.selected_tile_copy)
    GlobalVars.selected_tile_copy = tile.duplicate()
    GlobalVars.selected_tile_copy.instance_type = tile.instance_type
    GlobalVars.selected_tile_copy.rotation = GlobalVars.selected_tile.rotation
    GlobalVars.selected_tile_copy.scale = Vector3(1,1,1)
    GlobalVars.selected_tile_copy.visible = false
    add_child(GlobalVars.selected_tile_copy)
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            var slot = GRID_MAP[x][y][0]
            if slot != null:
                slot.set_unavailable()
                if slot_compatible(x, y, GlobalVars.selected_tile_copy):
                    slot.set_available()
    
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
