extends Control

func ready():
    $DebugLabel.text = "Debug : " + str(GlobalVars.debug)

func on_has_start_key_path():
    $StartKeyLabel.text = "Start => Key : OK"

func on_has_key_exit_path():
    $KeyExitLabel.text = "Key => Exit : OK"

func on_board_tipped(new_angle):
    if new_angle == 0 :
        $Balance/BoardAngleLabel.text = "Board angle : Perfectly balanced"
    elif (new_angle > 0 and new_angle < 8) or (new_angle < 0 and new_angle > -8) :
        $Balance/BoardAngleLabel.text = "Board angle : Fine"
    elif new_angle >= 8 or new_angle <= -8 :
        $Balance/BoardAngleLabel.text = "Board angle : Dangerous"

func on_board_toppled():
    $BoardToppledLabel.text = "Board toppled : true"

func heal_player():
    $Crawler/LifeBar.value = $Crawler/LifeBar.max_value
    $Crawler/LifeBar/Label.text = str($Crawler/LifeBar.value) + " / " + str($Crawler/LifeBar.max_value)

func player_power_up():
    $Crawler/Label.text = "Power : " + str(GlobalVars.player_power)

func blesser_le_joueur():
    $Crawler/LifeBar.value -= 1
    $Crawler/LifeBar/Label.text = str($Crawler/LifeBar.value) + " / " + str($Crawler/LifeBar.max_value)
    if $Crawler/LifeBar.value <= 0 :
        get_parent().game_over()

func update_score():
    $Crawler/LabelScore.text = "Score : " + str(GlobalVars.score)

func update_cave():
    $Crawler/LabelCave.text = "Cave level : " + str(GlobalVars.cave_level)

func reroll_refresh():
    $Reroll/LabelRerollCount.text = str(GlobalVars.reroll_number)

func player_potion_up():
    $Potion/LabelPotion.text = str(GlobalVars.player_potion)

func switch_reroll_potion():
    $Potion.visible = !$Potion.visible
    $Reroll.visible = !$Reroll.visible

func hide_show_balance():
    $Balance.visible = !$Balance.visible
    $Balance/BoardAngleLabel.text = "Board angle : Perfectly balanced"
