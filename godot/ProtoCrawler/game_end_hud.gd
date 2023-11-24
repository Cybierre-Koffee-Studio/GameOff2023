extends Control

func _ready():
    $Score/ScoreLabel.text = "Score : " + str(GlobalVars.score)
    $Score/ScoreCave.text = "Cave level : " + str(GlobalVars.cave_level)
