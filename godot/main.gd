extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
    $knight.position.y = 50
    var delay = 10
    var i = 0
    var tween = get_tree().create_tween()
    for tile in $Tiles.get_children():
        tile.position.y = 50
        tween.parallel().tween_property(tile, "position:y", -0.2, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_delay(delay + 0.2 * i)
        i+=1
    tween.parallel().tween_property($knight, "position:y", 0.2, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_delay(delay + 4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
