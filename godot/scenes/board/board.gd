extends Node3D

signal tile_placed

const GRID_SIZE = 11
# taille de la zone périphérique où les tuiles clé et sortie pourront être placées
const PERIPHERAL_ZONE_WIDTH = max(floor(GRID_SIZE / 4), 1)

const tile_slot_scene = preload("res://scenes/board/tile_slot.tscn")
const key_tokenScene = preload("res://scenes/tokens/key_token.tscn")
const exit_tokenScene = preload("res://scenes/tokens/exit_token.tscn")

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

var astar_grid : AStarGrid2D

var start_coordinates : Vector2i
var key_coordinates : Vector2i
var exit_coordinates : Vector2i

func _ready():
    $Mesh.scale = Vector3(GRID_SIZE, 0.5, GRID_SIZE)
    GRID_MAP.resize(GRID_SIZE)
    init_astar_grid()
    for i in GRID_SIZE*GRID_SIZE:
        var tile_slot: Node3D = tile_slot_scene.instantiate()
        var x = i/GRID_SIZE
        var y = i%GRID_SIZE
        tile_slot.position.x = x - GRID_SIZE/2
        tile_slot.position.z = y - GRID_SIZE/2
        tile_slot.position.y = 0.5
        tile_slot.connect("add_tile", on_add_tile)
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
    # Les emplacements vides sont des solides, le path finding 
    # ne trouve pas de chemin
    for i in range(0, GRID_SIZE*3):
        for j in range(0, GRID_SIZE*3):
            astar_grid.set_point_solid(Vector2i(j, i), true)
        
    place_starting_tile()
    
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
    #   si random_position=0 : clé en haut, sortie en bas
    #   si random_position=1 : clé à droite, sortie à gauche
    #   si random_position=2 : clé en bas, sortie en haut
    #   si random_position=3 : clé à gauche, sortie à droite
    var random_position = randi_range(0, 3)
    var key_tile_zone = random_position
    var exit_tile_zone = (random_position + 2) % 4
    place_key_tile(zones, key_tile_zone)
    place_exit_tile(zones, exit_tile_zone)
    
func init_astar_grid():
    astar_grid = AStarGrid2D.new()
    astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar_grid.region = Rect2i(0, 0, GRID_SIZE*3, GRID_SIZE*3)
    astar_grid.update()

func place_starting_tile():
    # placement de la tuile de départ
    var start_tile = tile_scene.instantiate()
    start_tile.init(Tile.TYPE.CENTER)
    start_tile.position = Vector3(0, 0.5, 0)
    start_coordinates = Vector2i(GRID_SIZE*3/2, GRID_SIZE*3/2)
    map_tile(GRID_SIZE/2, GRID_SIZE/2, [0b1111,0b0000])
    add_child(start_tile)
    
func place_key_tile(zones, key_tile_zone):
    # placement de la tuile clé
    var key_tile = tile_scene.instantiate()
    var key_tile_x = randi_range(zones[key_tile_zone][0].x, zones[key_tile_zone][1].x)
    var key_tile_y = randi_range(zones[key_tile_zone][0].y, zones[key_tile_zone][1].y)
    key_tile.init(possible_tiles.pick_random())
    key_tile.position = Vector3(
        key_tile_x - GRID_SIZE/2,
        0.5,
        key_tile_y - GRID_SIZE/2
    )
    var key_tile_rotation = rotations.pick_random()
    key_tile.rotation.y = deg_to_rad(key_tile_rotation)
    add_child(key_tile)
    key_coordinates = Vector2i(key_tile_x*3+1, key_tile_y*3+1)
    map_tile(key_tile_x, key_tile_y, key_tile.get_tile_data())
    # avec le marqueur de clé dessus
    var key_token = key_tokenScene.instantiate()
    key_token.position = Vector3(key_tile.position.x, key_tile.position.y + 0.1, key_tile.position.z)
    add_child(key_token)

func place_exit_tile(zones, exit_tile_zone):
    # placement de la tuile sortie
    var exit_tile = tile_scene.instantiate()
    var exit_tile_x = randi_range(zones[exit_tile_zone][0].x , zones[exit_tile_zone][1].x)
    var exit_tile_y = randi_range(zones[exit_tile_zone][0].y, zones[exit_tile_zone][1].y)
    exit_tile.init(possible_tiles.pick_random())
    exit_tile.position = Vector3(
        exit_tile_x - GRID_SIZE/2,
        0.5,
        exit_tile_y - GRID_SIZE/2
    )
    var exit_tile_rotation = rotations.pick_random()
    exit_tile.rotation.y = deg_to_rad(exit_tile_rotation)
    add_child(exit_tile)
    exit_coordinates = Vector2i(exit_tile_x*3+1, exit_tile_y*3+1)
    map_tile(exit_tile_x, exit_tile_y, exit_tile.get_tile_data())
    # avec le marqueur de sortie dessus
    var exit_token = exit_tokenScene.instantiate()
    exit_token.position = Vector3(exit_tile.position.x, exit_tile.position.y + 0.1, exit_tile.position.z)
    add_child(exit_token)

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
    # haut
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3), ((tile_data[1] & 0b1000) == 0b1000))
    # droite
    astar_grid.set_point_solid(Vector2i(x*3+2, y*3+1), ((tile_data[1] & 0b0100) == 0b0100))
    # bas
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3+2), ((tile_data[1] & 0b0010) == 0b0010))
    # gauche
    astar_grid.set_point_solid(Vector2i(x*3, y*3+1), ((tile_data[1] & 0b0001) == 0b0001))
    # centre
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3+1), false)
    
    var path_from_start_to_key =  astar_grid.get_point_path(start_coordinates, key_coordinates)
    var path_from_key_to_exit =  astar_grid.get_point_path(key_coordinates, exit_coordinates)
    print("====================")
    print_path()
    print("====================")
    print("Path from start to key exists :" + str(!path_from_start_to_key.is_empty()))
    print("Path from key to exit exists :" + str(!path_from_key_to_exit.is_empty()))

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
    tile.get_neighbour_tile_color()
    var tween = create_tween()
    tween.tween_property(tile, "position:y", 0.5, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
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

func print_path():
    var line : String = ""
    for j in range(0, GRID_SIZE*3):
        for i in range(0, GRID_SIZE*3):
            if astar_grid.is_point_solid(Vector2i(i,j)):
                line = line + "X"
            else:
                line = line + "O"
        print(line)
        line = ""
            
