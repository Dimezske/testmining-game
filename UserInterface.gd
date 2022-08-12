extends CanvasLayer


func _input(event):
	if event.is_action_pressed("Inventory"):
		$Inventory.visible = !$Inventory.visible
		$Inventory.initialize_inventory()
		pass
func _ready():
	pass # Replace with function body.
