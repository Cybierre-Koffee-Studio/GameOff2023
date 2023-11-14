extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
    $Plateau.connect("has_path_start_key", $GameHUD.on_has_start_key_path)
    $Plateau.connect("has_path_key_exit", $GameHUD.on_has_key_exit_path)
    $Plateau.connect("board_tipped", $GameHUD.on_board_tipped)
    $Plateau.connect("board_toppled", $GameHUD.on_board_toppled)
    $Plateau.connect("tile_placed", $Hand.on_tile_placed)
    $Hand.connect("tile_selected", $Plateau.on_tile_selected)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass
