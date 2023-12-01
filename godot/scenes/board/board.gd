extends Node3D
class_name Board

signal tile_placed
signal has_path_start_key
signal has_path_key_exit
signal path_key_exit_impossible
signal path_start_key_impossible
signal board_full
signal board_toppled
signal board_tipped(new_angle)
signal mouvement_finished

const tile_slot_scene = preload("res://scenes/board/tile_slot.tscn")
const key_tokenScene = preload("res://scenes/tokens/key_token.tscn")
const exit_tokenScene = preload("res://scenes/tokens/exit_token.tscn")
const tile_scene = preload("res://scenes/tiles/tile.tscn")
const possible_tiles : Array[Tile.TYPE] = [Tile.TYPE.CENTER, Tile.TYPE.CORNER, Tile.TYPE.CORRIDOR, Tile.TYPE.STRAIGHT]
const rotations = [0, 90, 180, 270]

const BOARD_THICKNESS = 0.1

@export var GRID_SIZE = 5
@export var pathfinding_service: PathfindingService

# taille de la zone périphérique où les tuiles clé et sortie pourront être placées
@onready var PERIPHERAL_ZONE_WIDTH = max(floor(GRID_SIZE / 4), 1)

# on détermine les limites des zones périphériques du plateau
# pour chaque zone le tableau contient dans l'ordre :
#   la limite en haut à gauche de la zone
#   la limite en bas à droite de la zone
@onready var zones = [
        # 0 : zone du haut
        [Vector2(0, 0), Vector2(GRID_SIZE-1, PERIPHERAL_ZONE_WIDTH-1)],
        # 1 : à droite
        [Vector2(GRID_SIZE-PERIPHERAL_ZONE_WIDTH, 0), Vector2(GRID_SIZE-1, GRID_SIZE-1)],
        # 2 : en bas
        [Vector2(0, GRID_SIZE-PERIPHERAL_ZONE_WIDTH), Vector2(GRID_SIZE-1, GRID_SIZE-1)],
        # 4 : à gauche
        [Vector2(0, 0), Vector2(PERIPHERAL_ZONE_WIDTH-1, GRID_SIZE-1)]
    ]

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

var start_coordinates : Vector2i
var key_coordinates : Vector2i
var exit_coordinates : Vector2i
var selected_tile_copy : Tile
var current_inclination

var key_token : Node3D
var exit_token : Node3D

func _ready():
    pass

func _init_board(grid_size):
    GRID_SIZE = grid_size
    $Map.scale = Vector3(GRID_SIZE, $Map.scale.y, GRID_SIZE)
    $Border.scale = Vector3(GRID_SIZE + 1, $Border.scale.y, GRID_SIZE + 1)
    GRID_MAP.resize(GRID_SIZE)

    # Init du pathfinding
    pathfinding_service.size = GRID_SIZE*3
    pathfinding_service.init_astar_grid()

    for i in GRID_SIZE*GRID_SIZE:
        var tile_slot: Node3D = tile_slot_scene.instantiate()
        tile_slot.board = self
        var x = i/GRID_SIZE
        var y = i%GRID_SIZE
        tile_slot.position.x = x - GRID_SIZE/2
        tile_slot.position.z = y - GRID_SIZE/2
        tile_slot.position.y = BOARD_THICKNESS
        add_child(tile_slot)
        if GRID_MAP[x] == null:
            GRID_MAP[x] = []
            GRID_MAP[x].resize(GRID_SIZE)
        # pour chaque emplacement du plateau on intialise les infos de GRID_MAP
        GRID_MAP[x][y] = [
            # slot
            tile_slot,
            # aucune ouverture voisine
            0b0000,
            # aucun mur voisin
            0b0000
        ]
    PERIPHERAL_ZONE_WIDTH = max(floor(GRID_SIZE / 4), 1)
    zones = [
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
    #   si random_position=0 : clé en haut, sortie en bas
    #   si random_position=1 : clé à droite, sortie à gauche
    #   si random_position=2 : clé en bas, sortie en haut
    #   si random_position=3 : clé à gauche, sortie à droite
    var random_position = randi_range(0, 3)
    var key_tile_zone = random_position
    var exit_tile_zone = (random_position + 2) % 4
    place_starting_tile()
    place_key_tile(key_tile_zone)
    place_exit_tile(exit_tile_zone)
    GlobalVars.started = true

func place_starting_tile():
    # placement de la tuile de départ
    var start_tile = tile_scene.instantiate()
    start_tile.init(Tile.TYPE.CENTER, true)
    start_tile.position = Vector3(0, BOARD_THICKNESS+0.003, 0)
    start_coordinates = Vector2i(GRID_SIZE*3/2, GRID_SIZE*3/2)
    map_tile(GRID_SIZE/2, GRID_SIZE/2, [0b1111,0b0000])
    add_child(start_tile)
    get_parent().position_tuile_centrale = start_tile.position

func place_key_tile(key_tile_zone):
    # placement de la tuile clé
    var key_tile = tile_scene.instantiate()
    var key_tile_x = randi_range(zones[key_tile_zone][0].x, zones[key_tile_zone][1].x)
    var key_tile_y = randi_range(zones[key_tile_zone][0].y, zones[key_tile_zone][1].y)
    key_tile.init(Tile.TYPE.CENTER, true)
    key_tile.position = Vector3(
        key_tile_x - GRID_SIZE/2,
        BOARD_THICKNESS+0.003,
        key_tile_y - GRID_SIZE/2
    )
    var key_tile_rotation = rotations.pick_random()
    key_tile.rotate_subtile(key_tile_rotation)
    add_child(key_tile)
    key_coordinates = Vector2i(key_tile_x*3+1, key_tile_y*3+1)
    map_tile(key_tile_x, key_tile_y, key_tile.get_tile_data())
    # avec le marqueur de clé dessus
    key_token = key_tokenScene.instantiate()
    key_token.position = Vector3(key_tile.position.x, key_tile.position.y + 0.1, key_tile.position.z)
    add_child(key_token)

    var la_cle = preload("res://ProtoCrawler/key.tscn").instantiate()
    la_cle.position = Vector3(key_tile.position.x, key_tile.position.y + 0.1, key_tile.position.z)
    add_child(la_cle)

func place_exit_tile(exit_tile_zone):
    # placement de la tuile sortie
    var exit_tile = tile_scene.instantiate()
    var exit_tile_x = randi_range(zones[exit_tile_zone][0].x , zones[exit_tile_zone][1].x)
    var exit_tile_y = randi_range(zones[exit_tile_zone][0].y, zones[exit_tile_zone][1].y)
    exit_tile.init(Tile.TYPE.CENTER, true)
    exit_tile.position = Vector3(
        exit_tile_x - GRID_SIZE/2,
        BOARD_THICKNESS+0.003,
        exit_tile_y - GRID_SIZE/2
    )
    var exit_tile_rotation = rotations.pick_random()
    exit_tile.rotate_subtile(exit_tile_rotation)
    add_child(exit_tile)
    exit_coordinates = Vector2i(exit_tile_x*3+1, exit_tile_y*3+1)
    map_tile(exit_tile_x, exit_tile_y, exit_tile.get_tile_data())
    # avec le marqueur de sortie dessus
    exit_token = exit_tokenScene.instantiate()
    exit_token.position = Vector3(exit_tile.position.x, exit_tile.position.y + 0.1, exit_tile.position.z)
    add_child(exit_token)

    var la_trappe = preload("res://ProtoCrawler/trappe.tscn").instantiate()
    la_trappe.position = Vector3(exit_tile.position.x, exit_tile.position.y + 0.1, exit_tile.position.z)
    add_child(la_trappe)
    la_trappe.connect("game_end", get_parent().on_game_end)

# permet de mettre à jour les données des emplacements voisins dans GRID_MAP lors du placement d'une nouvelle tuile
func map_tile(x, y, tile_data):
    # on supprime le tile_slot à l'emplacement où la tuile est posée
    GRID_MAP[x][y][0].queue_free()
    # on déréférence le tile_slot dans GRID_MAP
    GRID_MAP[x][y][0] = null
    if y > 0:
        # modification des infos de l'emplacement en haut de la tuile posée
        # ouvertures
        GRID_MAP[x][y-1][1] = GRID_MAP[x][y-1][1] | ((tile_data[0] & 0b1000) >> 2)
        # murs
        GRID_MAP[x][y-1][2] = GRID_MAP[x][y-1][2] | ((tile_data[1] & 0b1000) >> 2)

    if x < GRID_SIZE - 1:
        # modification des infos de l'emplacement à droite de la tuile posée
        # ouvertures
        GRID_MAP[x+1][y][1] = GRID_MAP[x+1][y][1] | ((tile_data[0] & 0b0100) >> 2)
        # murs
        GRID_MAP[x+1][y][2] = GRID_MAP[x+1][y][2] | ((tile_data[1] & 0b0100) >> 2)

    if y < GRID_SIZE - 1:
        # modification des infos de l'emplacement en bas de la tuile posée
        # ouvertures
        GRID_MAP[x][y+1][1] = GRID_MAP[x][y+1][1] | ((tile_data[0] & 0b0010) << 2)
        # murs
        GRID_MAP[x][y+1][2] = GRID_MAP[x][y+1][2] | ((tile_data[1] & 0b0010) << 2)

    if x > 0:
        # modification des infos de l'emplacement à gauche de la tuile posée
        # ouvertures
        GRID_MAP[x-1][y][1] = GRID_MAP[x-1][y][1] | ((tile_data[0] & 0b0001) << 2)
        # murs
        GRID_MAP[x-1][y][2] = GRID_MAP[x-1][y][2] | ((tile_data[1] & 0b0001) << 2)

    # Modification de l'astar_grid pour le pathfinding
    # en indiquant les murs et les ouvertures de la tuile placée
    pathfinding_service.set_astargrid_solidity(x, y, tile_data[1])
    if GlobalVars.started:
        check_paths()

# permet de vérifier si une tuile (tile) peut être placée à un emplacement (x, y)
# en fonction de ce qu'il y a autour dudit emplacement
func slot_compatible(x, y, tile):
    var tile_data = tile.get_tile_data()
    # il y a 3 règles de placement :
    return (
        # au moins une tuile doit être adjacente à l'emplacement
        #   -> on regarde s'il y a au moins une ouverture ou un mur qui borde l'emplacement
        GRID_MAP[x][y][1] | GRID_MAP[x][y][2] > 0
        # les ouvertures de la tuile placée ne doivent pas être adjacentes à un mur
        #   -> on vérifie qu'aucun mur adjacent à l'emplacement ne se trouve du même côté qu'une ouverture de la tuile placée
        && !(GRID_MAP[x][y][2] & tile_data[0])
        # les murs de la tuile placée ne doivent pas se retrouver en face d'une ouverture de tuile voisine
        #   -> on vérifie qu'aucune ouverture adjacente à l'emplacement ne se trouve du même côté qu'un mur de la tuile placée
        && !(GRID_MAP[x][y][1] & tile_data[1])
    )

func add_tile(_tile_copy):
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            var slot = GRID_MAP[x][y][0]
            if slot != null:
                slot.set_unavailable()
    var tile = selected_tile_copy
    remove_child(selected_tile_copy)
    tile.poids = selected_tile_copy.poids
    tile.position = selected_tile_copy.position
    selected_tile_copy.disconnect("select_tile", add_tile)
    selected_tile_copy = null
    emit_signal("tile_placed", tile)
    tile.position.y = 50
    add_child(tile)
    var tile_x = tile.position.x + GRID_SIZE/2
    var tile_y = tile.position.z + GRID_SIZE/2
    var tween = create_tween()
    tween.tween_property(tile, "position:y", BOARD_THICKNESS, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_callback(map_tile.bind(tile_x, tile_y, tile.get_tile_data()))
#    tip(tile.position.x*(tile.poids/2))
    tip(tile.position.x*tile.poids)
    GlobalVars.add_score(tile.poids)

func check_paths():
    if is_path_start_key(): # && !GlobalVars.got_key:
        emit_signal("has_path_start_key")
    if is_path_key_exit(): # && GlobalVars.got_key && !GlobalVars.at_exit:
        emit_signal("has_path_key_exit")
    if is_path_start_key_impossible():
        emit_signal("path_start_key_impossible")
    if is_path_key_exit_impossible():
        emit_signal("path_key_exit_impossible")

func get_start_key_path():
    var path_start_key = pathfinding_service.get_path_a_to_b(start_coordinates, key_coordinates)
    var copy : Array = path_start_key.duplicate(true)
    for i in range(0, path_start_key.size()):
        if i%3 != 0 :
            path_start_key.erase(copy[i])
    return path_start_key.map(func(a: Vector2i): return a/3)

func get_key_exit_path():
    var path_key_exit = pathfinding_service.get_path_a_to_b(key_coordinates, exit_coordinates)
    var copy : Array = path_key_exit.duplicate(true)
    for i in range(0, path_key_exit.size()):
        if i%3 != 0 :
            path_key_exit.erase(copy[i])
    return path_key_exit.map(func(a: Vector2i): return a/3)

func tip(angle):
    var tween = create_tween()
    var new_angle = snapped(rotation_degrees.z - angle,0.01)
    if abs(new_angle) > GRID_SIZE*4/2 :
        if rotation_degrees.z > 0:
            new_angle = 180
        else:
            new_angle = -180
        tween.tween_property(self, "rotation_degrees:z", new_angle, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        tween.tween_callback(emit_signal.bind("board_toppled"))
    else:
        tween.tween_property(self, "rotation_degrees:z", new_angle, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.6)
        emit_signal("board_tipped", new_angle)

func set_flat():
    rotation_degrees.z = 0

func on_tile_selected(tile: Tile):
    GlobalVars.selected_tile_rotation = tile.get_rota_degrees()
    if selected_tile_copy != null:
        remove_child(selected_tile_copy)
        if selected_tile_copy.has_item():
            disconnect("tile_placed", selected_tile_copy.item.on_tile_placed)
            selected_tile_copy.item = null
    selected_tile_copy = tile.duplicate()
    selected_tile_copy.poids = tile.poids
    selected_tile_copy.instance_type = tile.instance_type
    selected_tile_copy.rotate_subtile(GlobalVars.selected_tile_rotation)
    selected_tile_copy.scale = Vector3(1,1,1)
    selected_tile_copy.visible = false
    if tile.has_item():
        selected_tile_copy.item = tile.item.duplicate()
        connect("tile_placed", selected_tile_copy.item.on_tile_placed)
    selected_tile_copy.connect("select_tile", add_tile)
    add_child(selected_tile_copy)
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            var slot = GRID_MAP[x][y][0]
            if slot != null:
                slot.set_unavailable()
                if slot_compatible(x, y, selected_tile_copy):
                    slot.set_available()

func is_path_start_key() -> bool :
    return pathfinding_service.is_path_a_to_b(start_coordinates, key_coordinates)

func is_path_key_exit() -> bool :
    return pathfinding_service.is_path_a_to_b(key_coordinates, exit_coordinates)

func is_path_key_exit_impossible() -> bool :
    return pathfinding_service.is_path_a_to_b_inverse(key_coordinates, exit_coordinates)

func is_path_start_key_impossible() -> bool :
    return pathfinding_service.is_path_a_to_b_inverse(key_coordinates, exit_coordinates)

func on_reroll():
    if selected_tile_copy != null:
        remove_child(selected_tile_copy)
        disconnect("tile_placed", selected_tile_copy.item.on_tile_placed)
    selected_tile_copy = null
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            var slot = GRID_MAP[x][y][0]
            if slot != null:
                slot.set_unavailable()
