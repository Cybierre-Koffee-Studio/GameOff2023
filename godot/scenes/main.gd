extends Node3D

const board_scene = preload("res://scenes/board/board.tscn")
const hud_scene = preload("res://HUD/GameHUD/game_hud.tscn")
const hand_scene = preload("res://scenes/hand/hand.tscn")
const game_over_scene = preload("res://HUD/GameOverScreen/game_over.tscn")

@onready var hand : Hand = $Hand
@onready var board : Board = $Plateau
@onready var hud = $GameHUD

# Called when the node enters the scene tree for the first time.
func _ready():
    init()

func init():
    board.connect("has_path_start_key", hud.on_has_start_key_path)
    board.connect("has_path_key_exit", hud.on_has_key_exit_path)
    board.connect("board_tipped", hud.on_board_tipped)
    board.connect("board_toppled", hud.on_board_toppled)
    board.connect("board_toppled", on_board_toppled)
    board.connect("tile_placed", hand.on_tile_placed)
    board.exit_token.connect("exit_reached", on_exit_reached)
    hand.connect("tile_selected", board.on_tile_selected)

func on_replay(game_over_screen):
    game_over_screen.queue_free()
    board.queue_free()
    hud.queue_free()

    GlobalVars._init()

    board = board_scene.instantiate()
    add_child(board)
    hud = hud_scene.instantiate()
    add_child(hud)
    hand.discard_hand()
    hand.deal_hand(GlobalVars.hand_size)
    init()

func game_over():
    var game_over_instance = game_over_scene.instantiate()
    game_over_instance.connect("replay", on_replay)
    add_child(game_over_instance)

func on_board_toppled():
    game_over()

func _on_plateau_has_path_key_exit():
    GlobalVars.fin_reliee = true
    can_start_explo()

func _on_plateau_has_path_start_key():
    GlobalVars.key_reliee = true
    can_start_explo()

func can_start_explo():
    if GlobalVars.fin_reliee and GlobalVars.key_reliee :
        get_tree().call_group("MONSTRE_COFFRE", "activate")
        $joueur.set_cam_current()
        await get_tree().create_timer(2.5).timeout
        $Plateau.set_flat()

func on_exit_reached():
    game_over()
