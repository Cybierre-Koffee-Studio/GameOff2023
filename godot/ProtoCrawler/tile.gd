extends StaticBody3D

func _on_tile_zone_body_entered(_body):
    $tileZone.set_deferred("monitorable", false)
    $tileZone.set_deferred("monitoring", false)

func _on_tile_zone_body_exited(_body):
    $tileZone.set_deferred("monitorable", true)
    $tileZone.set_deferred("monitoring", true)
