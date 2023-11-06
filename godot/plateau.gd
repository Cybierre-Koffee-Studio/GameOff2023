extends Node3D

var sceneEmplacementTuile = load("res://emplacement_tuile.tscn")
var GRID_SIZE = 12

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in GRID_SIZE*GRID_SIZE:
        var emplacementTuile: Node3D = sceneEmplacementTuile.instantiate()
        emplacementTuile.position.x = i/GRID_SIZE - 5.5
        emplacementTuile.position.z = i%GRID_SIZE - 5.5
        emplacementTuile.position.y = 0.5
        add_child(emplacementTuile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
