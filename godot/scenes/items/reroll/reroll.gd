extends Item

func on_tile_placed(_tile):
    GlobalVars.change_reroll(1)
    queue_free()
