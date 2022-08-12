extends MarginContainer

func _physics_process(_delta):
	$HBoxContainer/VBoxContainer/Stat1.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	$HBoxContainer/VBoxContainer/Stat2.text = "Memory Static: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB"
