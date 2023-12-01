extends Control

func _ready():
    $CanvasLayer/Score/ScoreLabel.text = "Score : " + str(GlobalVars.score)
    $CanvasLayer/Score/ScoreCave.text = "Cave level : " + str(GlobalVars.cave_level)


func _on_button_pressed():
    get_parent().get_parent().next_level()
    queue_free()
