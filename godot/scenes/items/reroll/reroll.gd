extends Item

func on_placement():
    GlobalVars.reroll_number += 1

func on_pickup():
    print("Reroll picked up")
