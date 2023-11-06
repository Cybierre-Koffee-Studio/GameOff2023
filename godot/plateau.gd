extends Node3D

var sceneEmplacementTuile = load("res://emplacement_tuile.tscn")
var sceneTuile = load("res://tuile.tscn")
var GRID_SIZE = 12

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in GRID_SIZE*GRID_SIZE:
        var emplacementTuile: Node3D = sceneEmplacementTuile.instantiate()
        emplacementTuile.position.x = i/GRID_SIZE - 6
        emplacementTuile.position.z = i%GRID_SIZE - 6
        emplacementTuile.position.y = 0.5
        emplacementTuile.connect("add_tile", on_add_tile)
        add_child(emplacementTuile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
func on_add_tile(src):
    var tuile = sceneTuile.instantiate()
    tuile.position = src.position
    tuile.position.y = 50
    add_child(tuile)
    var tween = create_tween()
    tween.tween_property(tuile, "position:y", 0.5, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_callback(src.queue_free)
