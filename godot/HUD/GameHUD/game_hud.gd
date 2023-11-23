extends Control

func ready():
    $DebugLabel.text = "Debug : " + str(GlobalVars.debug)
    $Crawler/Label.text = "Power : " + str(GlobalVars.player_power)

func on_has_start_key_path():
    $StartKeyLabel.text = "Start => Key : OK"

func on_has_key_exit_path():
    $KeyExitLabel.text = "Key => Exit : OK"

func on_board_tipped(new_angle):
    $BoardAngleLabel.text = "Board angle : " + str(new_angle)

func on_board_toppled():
    $BoardToppledLabel.text = "Board toppled : true"

func heal_player():
    $Crawler/LifeBar.value = $Crawler/LifeBar.max_value

func player_power_up(valeur):
    $Crawler/Label.text = "Power : " + str(valeur)

func blesser_le_joueur():
    $Crawler/LifeBar.value -= 1
    if $Crawler/LifeBar.value <= 0 :
        get_parent().game_over()

