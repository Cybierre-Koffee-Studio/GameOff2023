extends Control

func on_has_start_key_path():
    $StartKeyLabel.text = "Start => Key : OK"

func on_has_key_exit_path():
    $KeyExitLabel.text = "Key => Exit : OK"

func on_board_tipped(new_angle):
    $BoardAngle.text = "Board angle : " + str(new_angle)

func on_board_toppled():
    $BoardToppled.text = "Board toppled : true"
