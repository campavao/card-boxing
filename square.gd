extends Node2D

@onready var Zone1 := $SquareZone
@onready var Zone2 := $SquareZone2
@onready var Zone3 := $SquareZone3
@onready var Zone4 := $SquareZone4

var zones = [Zone1, Zone2, Zone3, Zone4]

func is_complete():
	zones.all(is_zone_complete)
	
func is_zone_complete(zone: SquareZone):
	return zone.is_filled
