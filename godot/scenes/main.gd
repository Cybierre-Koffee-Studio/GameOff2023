extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
    $Plateau.connect("tile_placed", $hand.on_tile_placed)
    $hand.connect("tile_selected", $Plateau.on_tile_selected)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
