extends CanvasLayer
var isInventory : bool


func _input(_event):
	open_inventory()
	
func open_inventory():
	if Input.is_action_just_pressed("new_inventory"):
		isInventory = !isInventory
		if isInventory:
			$"GridContainer".visible = true
			print('true')
		else:
			$"GridContainer".visible = false
			print('false')
