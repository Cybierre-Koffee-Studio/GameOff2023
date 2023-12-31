extends Node
class_name PathfindingService

var astar_grid : AStarGrid2D
var astar_grid_inverse : AStarGrid2D
var size

func init_astar_grid():
    astar_grid = AStarGrid2D.new()
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    # On utilise l'heuristique Manhattan parce qu'on n'autorise pas les déplacements en diagonale
    astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid.region = Rect2i(0, 0, size, size)
    astar_grid.update()

    # L'AStarGrid inverse va permettre de savoir quand le start et la clé OU
    # la clé est l'exit ne peuvent plus être reliés
    astar_grid_inverse = AStarGrid2D.new()
    astar_grid_inverse.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar_grid_inverse.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid_inverse.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar_grid_inverse.region = Rect2i(0, 0, size, size)
    astar_grid_inverse.update()

    # Les emplacements vides sont des solides, le path finding
    # ne trouve pas de chemin
    for i in range(0, size):
        for j in range(0, size):
            astar_grid.set_point_solid(Vector2i(j, i), true)

    # Pour l'AStarGrid inverse, au début tout est possible
    for i in range(0, size):
        for j in range(0, size):
            astar_grid_inverse.set_point_solid(Vector2i(j, i), false)

func set_astargrid_solidity(x,y,tile_wall_data):
    # haut
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3), ((tile_wall_data & 0b1000) == 0b1000))
    astar_grid_inverse.set_point_solid(Vector2i(x*3+1, y*3), ((tile_wall_data & 0b1000) == 0b1000))
    # droite
    astar_grid.set_point_solid(Vector2i(x*3+2, y*3+1), ((tile_wall_data & 0b0100) == 0b0100))
    astar_grid_inverse.set_point_solid(Vector2i(x*3+2, y*3+1), ((tile_wall_data & 0b0100) == 0b0100))
    # bas
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3+2), ((tile_wall_data & 0b0010) == 0b0010))
    astar_grid_inverse.set_point_solid(Vector2i(x*3+1, y*3+2), ((tile_wall_data & 0b0010) == 0b0010))
    # gauche
    astar_grid.set_point_solid(Vector2i(x*3, y*3+1), ((tile_wall_data & 0b0001) == 0b0001))
    astar_grid_inverse.set_point_solid(Vector2i(x*3, y*3+1), ((tile_wall_data & 0b0001) == 0b0001))
    # centre
    astar_grid.set_point_solid(Vector2i(x*3+1, y*3+1), false)
    astar_grid_inverse.set_point_solid(Vector2i(x*3+1, y*3+1), false)
    #diagonales
    astar_grid_inverse.set_point_solid(Vector2i(x*3, y*3), true)
    astar_grid_inverse.set_point_solid(Vector2i(x*3, y*3+2), true)
    astar_grid_inverse.set_point_solid(Vector2i(x*3+2, y*3), true)
    astar_grid_inverse.set_point_solid(Vector2i(x*3+2, y*3+2), true)

func is_path_a_to_b(a_coordinates: Vector2i, b_coordinates: Vector2i) -> bool :
    var path_from_a_to_b =  astar_grid.get_point_path(a_coordinates, b_coordinates)
    return !path_from_a_to_b.is_empty()

func is_path_a_to_b_inverse(a_coordinates: Vector2i, b_coordinates: Vector2i) -> bool :
    var path_from_a_to_b =  astar_grid_inverse.get_point_path(a_coordinates, b_coordinates)
    return path_from_a_to_b.is_empty()

func get_path_a_to_b(a_coordinates: Vector2i, b_coordinates: Vector2i) -> Array :
    return astar_grid.get_point_path(a_coordinates, b_coordinates)

func get_path_a_to_b_inverse(a_coordinates: Vector2i, b_coordinates: Vector2i) -> Array :
    return astar_grid_inverse.get_point_path(a_coordinates, b_coordinates)

func print_astar_grid():
    var line : String = ""
    for j in range(0, size):
        for i in range(0, size):
            if astar_grid.is_point_solid(Vector2i(i,j)):
                line = line + "X"
            else:
                line = line + "O"
        print(line)
        line = ""

func print_astar_grid_inverse():
    var line : String = ""
    for j in range(0, size):
        for i in range(0, size):
            if astar_grid_inverse.is_point_solid(Vector2i(i,j)):
                line = line + "X"
            else:
                line = line + "O"
        print(line)
        line = ""
