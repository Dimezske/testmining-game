extends KinematicBody2D

class_name Player, "res://Assets/Characters/chacter1.png"

onready var Tool: Node2D = get_node("Position2D/Tools")
onready var Weapon: Node2D = get_node("Position2D/Weapons")
onready var parent = get_parent()

var weapon = []
var current_weapon = [] 

onready var items = preload("res://Item.tscn")
onready var animated_sprite = $AnimatedSprite
onready var velocity = Global.player_velocity
onready var states = $StateMachine

export (int) var speed = 200
var dir = [0,1,2,3]
var player_in_range : bool
var isHoldingTool : bool
var isHoldingWeapon : bool
var isLazer : bool

func _ready():
	self.global_position = Global.player_initial_map_position
	#states.init(self)

func _physics_process(_delta):
	_get_input()
	
	get_tool_pickup()
	get_weapon_pickup()
	drop_tool()
	#toggle_lazer()
	
	
	if Input.is_action_just_pressed('fire'): # Test if button is pressed
		for weapon in $Position2D/Weapons.get_children(): # Iterate over all weapons
			if 'fire' in weapon: # Does this "weapon" essentially have a fire button?
				weapon.fire() # Fire the weapon
				print('fire')
	
# Player Movements
func _get_input():
	velocity = Vector2()
	speed = Global.player_speed
	#states = $StateMachine/Idle
	if Input.is_action_pressed("sprint"):
		#states = $StateMachine/Run
		Global.player_isRunning = true 
		speed = 300
	else:
		speed = 200

	if Input.is_action_pressed("move-right"):
		Global.player_direction = "0"
		velocity.x += 1
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-left"):
		Global.player_direction = "1"
		velocity.x -= 1
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-down"):
		Global.player_direction = "2"
		velocity.y += 1
		if $Footsteps.playing == false:
			$Footsteps.play()
	if Input.is_action_pressed("move-up"):
		Global.player_direction = "3"
		velocity.y -= 1
		if $Footsteps.playing == false:
			$Footsteps.play()
	
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	
	# not sure what these are for
	for child in self.get_children():
		if child.is_in_group("Position2D/Tools"):
			child.animate(velocity)
	for child in self.get_children():
		if child.is_in_group("Position2D/Weapons"):
			child.animate(velocity)
			
	#Player Animations for Idle and Walk
	if velocity == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Idle")
	else:
		$AnimationTree.get("parameters/playback").travel("Walk")
		$AnimationTree.set("parameters/Idle/blend_position", velocity)
		$AnimationTree.set("parameters/Walk/blend_position", velocity)
	#Animation hold
	for weapon in $Position2D/Weapons.get_children(): # Iterate over all weapons
		if 'parent_velocity' in weapon: # Does this "weapon" want to receive the player's velocity?
			weapon.parent_velocity = velocity
#Tool pickups
func get_tool_pickup():
	if Input.is_action_just_pressed("interact"):
		for area in $ItemPickupCollision.get_overlapping_areas():
			if area.is_in_group("Tools"):
				area.get_parent().remove_child(area)
				area.position = Vector2(0,0)
				$Position2D/Tools.add_child(area)
				isHoldingTool = true
#  working on a Drop Tool Method
func drop_tool():
	if Input.is_action_just_pressed("drop"):
		for child in self.get_children():
			child.is_in_group("Position2D/Tools")
			
#allow for weapon to be picked up, set its position attached to the player
func _input(event):
	if event.is_action_pressed("interact"):
		if $ItemPickupCollision.items_in_range.size() > 0:
			var pickup_item = $ItemPickupCollision.items_in_range.values()[0]
			pickup_item.pick_up_item(self)
			$ItemPickupCollision.items_in_range.erase(pickup_item)
func get_weapon_pickup():
	if Input.is_action_just_pressed("interact"):
		for area in $ItemPickupCollision.get_overlapping_areas():
			if area.is_in_group("Weapons"):
				area.get_parent().remove_child(area)
				area.position = Vector2(0,-25)
				$Position2D/Weapons.add_child(area)
				isHoldingWeapon = true
				#if isHoldingWeapon == true:
				
				# someone told me to put this here it has comments already
				for weapon in $Position2D/Weapons.get_children(): # Iterate over all weapons
					if 'fire' in weapon: # Does this "weapon" essentially have a fire button?
						weapon.fire() # Fire the weapon
						print('fire')
				#else:
					#pass
# here for later

func toggle_lazer():
	var lazer_attachment = get_node("Position2D/Weapons/M4A1/LazerBeam")
	if Input.is_action_just_pressed("Lazer"):
		if isHoldingWeapon:
			print("hasWeapon")
			isLazer = !isLazer
			if isLazer:
				lazer_attachment.visible = true
				#isLazer = true
				print('lazer true')
			else:
				lazer_attachment.visible = false
				#isLazer = false
				print('lazer false')


#onready var GunPos: = $Position2D/Weapons
#var gun_data = {
#	m4a1 = preload("res://M4A1.tscn")
#}
#func equip_gun(gun_type: String):
#	for gun in GunPos.get_children():
#		gun.queue_free()
#
#	var gun: Sprite = gun_data[gun_type].instance()
#	GunPos.add_child(gun)
#Signals
