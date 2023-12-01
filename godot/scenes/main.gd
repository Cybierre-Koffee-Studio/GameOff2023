extends Node3D

const board_scene = preload("res://scenes/board/board.tscn")
const hud_scene = preload("res://HUD/GameHUD/game_hud.tscn")
const hand_scene = preload("res://scenes/hand/hand.tscn")
const game_over_scene = preload("res://HUD/GameOverScreen/game_over.tscn")

const musics = {
    5: preload("res://audio/tiles-1.mp3"),
    7: preload("res://audio/tiles-2.mp3"),
    9: preload("res://audio/tiles-3.mp3"),
    11: preload("res://audio/tiles-4.mp3"),
    13: preload("res://audio/tiles-5.mp3")
}

var board_size = 5
var position_tuile_centrale = null
@onready var hand : Hand = $Camera3D/Hand
@onready var board : Board = $Plateau
@onready var hud = $GameHUD

# Called when the node enters the scene tree for the first time.
func _ready():
    init()

func init():
    $music.stop()
    $music.set_stream(musics[(min(board_size, 13))])
    $music.play()
    board._init_board(board_size)
    board.connect("has_path_start_key", hud.on_has_start_key_path)
    board.connect("has_path_start_key", _on_plateau_has_path_start_key)
    board.connect("has_path_key_exit", _on_plateau_has_path_key_exit)
    board.connect("has_path_key_exit", hud.on_has_key_exit_path)
    board.connect("path_start_key_impossible", on_board_toppled)
    board.connect("path_key_exit_impossible", on_board_toppled)
    board.connect("board_tipped", hud.on_board_tipped)
    board.connect("board_toppled", hud.on_board_toppled)
    board.connect("board_toppled", on_board_toppled)
    board.connect("tile_placed", hand.on_tile_placed)
    board.exit_token.connect("exit_reached", on_exit_reached)
    hand.connect("reroll_used", board.on_reroll)
    hand.connect("tile_selected", board.on_tile_selected)
    if !GlobalVars.is_connected("heal_player", hud.heal_player):
        GlobalVars.connect("heal_player", hud.heal_player)
    if !GlobalVars.is_connected("player_power_up", hud.player_power_up):
        GlobalVars.connect("player_power_up", hud.player_power_up)
    if !GlobalVars.is_connected("player_potion_up", hud.player_potion_up):
        GlobalVars.connect("player_potion_up", hud.player_potion_up)
    if !GlobalVars.is_connected("blesser_joueur", hud.blesser_le_joueur):
        GlobalVars.connect("blesser_joueur", hud.blesser_le_joueur)
    if !GlobalVars.is_connected("score_changed", hud.update_score):
        GlobalVars.connect("score_changed", hud.update_score)
    if !GlobalVars.is_connected("cave_level_changed", hud.update_cave):
        GlobalVars.connect("cave_level_changed", hud.update_cave)
    if !GlobalVars.is_connected("reroll_count_changed", hud.reroll_refresh):
        GlobalVars.connect("reroll_count_changed", hud.reroll_refresh)
    await get_tree().create_timer(1).timeout
    $joueur.position = position_tuile_centrale

func on_replay(game_over_screen):
    board_size = 5
    $DirectionalLight3D.visible = true
    $DirectionalLight3D2.visible = true
    $OmniLight3D2.visible = true
    game_over_screen.queue_free()
    board.queue_free()
    hud.queue_free()
    $Camera3D.current = true
    GlobalVars._init()
    $joueur.position = Vector3(0, 0, 0)
    board = board_scene.instantiate()
    add_child(board)
    hud = hud_scene.instantiate()
    add_child(hud)
    hand.discard_hand()
    hand.deal_hand(GlobalVars.hand_size)
    init()

func next_level():
    $DirectionalLight3D.visible = true
    $DirectionalLight3D2.visible = true
    $OmniLight3D2.visible = true
    board_size += 2
    hud.hide_show_balance()
    board.queue_free()
    $Camera3D.current = true
    GlobalVars._init()
    board = board_scene.instantiate()
    add_child(board)
    hand.discard_hand()
    hand.deal_hand(GlobalVars.hand_size)
    GlobalVars.level_ended()
    hud.switch_reroll_potion()
    init()

func game_over():
    var game_over_instance = game_over_scene.instantiate()
    game_over_instance.connect("replay", on_replay)
    add_child(game_over_instance)
    GlobalVars.game_over()

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
        get_tree().call_group("TILE", "check_murs_vides")
        var cam_pos = $Camera3D.position
        var tween1 = get_tree().create_tween()
        tween1.tween_property($Camera3D, "position", Vector3(0,0,0), 1.3)
        var tween2 = get_tree().create_tween()
        tween2.tween_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 1), 1.2)
        await get_tree().create_timer(1.5).timeout
        hud.switch_reroll_potion()
        board.set_flat()
        $DirectionalLight3D.visible = false
        $DirectionalLight3D2.visible = false
        $OmniLight3D2.visible = false
        hand.discard_hand()
        $joueur.set_cam_current()
        var tween3 = get_tree().create_tween()
        tween3.tween_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0), 0.7)
        hud.hide_show_balance()
        $Camera3D.position = cam_pos

func on_exit_reached():
    game_over()
