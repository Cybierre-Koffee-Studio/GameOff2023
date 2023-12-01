extends Item

func on_tile_placed(_tile: Tile):
    GlobalVars.change_reroll(1)
    _tile.item = null
    _tile.get_node("reroll").queue_free()
    queue_free()
