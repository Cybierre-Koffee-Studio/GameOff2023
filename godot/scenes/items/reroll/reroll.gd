extends Item

func on_tile_placed(_tile):
    GlobalVars.reroll_number += 1
    queue_free()
