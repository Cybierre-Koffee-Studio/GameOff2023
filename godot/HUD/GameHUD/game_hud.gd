extends Control

func ready():
    $DebugLabel.text = "Debug : " + str(GlobalVars.debug)

func on_has_start_key_path():
    $StartKeyLabel.text = "Start => Key : OK"

func on_has_key_exit_path():
    $KeyExitLabel.text = "Key => Exit : OK"

func on_board_tipped(new_angle):
    $BoardAngleLabel.text = "Board angle : " + str(new_angle)

func on_board_toppled():
    $BoardToppledLabel.text = "Board toppled : true"
