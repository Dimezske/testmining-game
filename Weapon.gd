extends Node2D
class_name Weapon
onready var playerPath = preload("res://Player.tscn")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var hitbox: Area2D = get_node("Node2D/Sprite/Hitbox")
const M4A1_bulletPath = preload("res://Bullet.tscn")
# true/false  on the ground
export(bool) var on_floor: bool = true

var parent_velocity = Vector2()
var velocity = Vector2()

var player_in_range : bool
var player_picked_up : bool
var hasWeapon : bool = false

var ammoAmount: int
var ammoMagazineAmount: int
var bulletSpread: Array = [0,0]
var bullet_speed = -500
var fire_rate = 2
var damage: float
var freeze: float
var hasEquiped: bool

# Attachment Mods
var hasAttachedMod1: bool
var hasAttachedMod2: bool
var hasAttachedMod3: bool
var hasAttachedMod4: bool
var hasAttachedMod5: bool
var isShooting : bool
var isLazer : bool # detect on/ off

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var item_name

var player = null
var being_picked_up = false

var Melee: Array = ["Sword"]
var melee_types = Melee
var Pistol: Array = ["Glock"]
var pistol_types = Pistol
var AssaultRifle: Array = ["M4A1", "AK47"]
var assault_rifle_types = AssaultRifle

onready var AssaultRifles : Dictionary =  {
	 "M4A1" : load("res://M4A1.tscn"),
	 "M4" : load("res://M4.tscn") 
}

#var assault_rifle_data = {
#	AssaultRifle == ["M4A1"]:
#		 load("res://M4A1.tscn"),
#	AssaultRifle == ["M4"]:
#		 load("res://M4.tscn")
var sidearm_data = {
		tac1 = load("res://Tac1.tscn")
	}

func _ready():
	item_name = "M4"
func _process(_delta):
	_guns_input()
	_assault_Rifle_Animation()
	_pick_up_weapon()
	toggle_lazer()
	hasAttachedMod1 = true
	hasAttachedMod2 = true
	
	if Input.is_action_just_pressed("interact"):
		if player_picked_up == true:
			player_picked_up = false
		else:
			if player_in_range == true:
				player_picked_up = true
				print(player_picked_up)
				Global.hasM4a1 = true
			hasWeapon = true
	if being_picked_up == false:
		pass
	else:
		PlayerInventory.add_item(item_name, 1)
		queue_free()
#Pick up weapon not sure why there is two in here and player but seesm to work
func _pick_up_item(body):
	player = body
	being_picked_up = true
	
func _pick_up_weapon():
	if Input.is_action_just_pressed("interact"):
		if player_picked_up == true:
			player_picked_up = false
		else:
			if player_in_range == true:
				player_picked_up = true
				print(player_picked_up)
				hasWeapon = true
#Guns Input Handler
func _guns_input():

	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("fire") and hasWeapon:
		if $M4A1_Shoot_Sound.playing == false:
			$M4A1_Shoot_Sound.play()
			isShooting = true
			fire() # == null
	if Input.is_action_pressed("fire") and hasWeapon:
		if $M4A1_Shoot_Sound.playing == false:
			$M4A1_Shoot_Sound.play()
			isShooting = true
			fire() # == null
	else:
		isShooting = false
		# not sure why there are two event handlers of the firing of the gun
		
#Primary Equiped not sure what it does but it should be something to signafy that the weapon is equiped
#And there is also secondaries catagories
func equip_assaultRifle1(assault_rifle_type: String):
	var _player = playerPath.instance()
	var GunPos: Player = _player.get_node("Position2D/Weapons")
	for assaultrifle in GunPos.get_children():
		assaultrifle.queue_free()
	var assaultrifle : Sprite = AssaultRifles[assault_rifle_type].instance()
	GunPos.add_child(assaultrifle)
	
# Secondary
func equip_sideArm(sidearm_type: String):
	var _player = playerPath.instance()
	var GunPos2: Player = _player.get_node("Position2D/Weapons")
	for sidearm in GunPos2.get_children():
		sidearm.queue_free()
	var sidearm: Sprite = sidearm_data[sidearm_type].instance()
	GunPos2.add_child(sidearm)
	
#Modifications of the gun to be attached or detached
# requires something for the inventory for the 5 mods slots in the big inventory
func assaultRifle_mods():
	if hasAttachedMod1 == true:
		$Node2D/Sprite/Mods/Silencer2.visible = true
	if hasAttachedMod2 == true:
		$Node2D/Sprite/Mods/LazerGreen.visible = true
	else:
		$Node2D/Sprite/Mods/Silencer2.visible = false
		$Node2D/Sprite/Mods/LazerGreen.visible = false
#Signals
#Entered the area of the weapon 
func _on_M4_body_entered(body):
	if body.name == "Player":
		print("player detected")
		player_in_range = true
		if body.has_method("add_weapon"):
			body.add_weapon(self)
			SavedData.weapons[SavedData.equipped_weapon_index] += 1
# Exited the area of the weapon
func _on_M4_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		
#Shooting method
func fire():
	var player = playerPath.instance()
	var bullet_instance = M4A1_bulletPath.instance()
	# Left
	
	if Global.player_direction == "0":
		bullet_speed = 500
		print('FIRE!')
		print(Global.player_direction)
		isShooting = true 
		bullet_instance.position = $Node2D/Sprite/Muzzle.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		look_at(get_global_mouse_position())
		$Node2D/Sprite.flip_h = false
		$Node2D/Sprite.flip_v = false
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().get_root().add_child(bullet_instance)
	
	#Right
	if Global.player_direction == "1":
		$Node2D/Sprite.flip_h = false
		bullet_speed = 500
		print('FIRE!')
		print(Global.player_direction)
		isShooting = true 
		bullet_instance.position = $Node2D/Sprite/Muzzle.get_global_position()
		#bullet_instance.position = $Muzzle.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		look_at(get_global_mouse_position())
		#$Node2D/Sprite.flip_h = true
		$Node2D/Sprite.flip_v = true
		$Node2D/Sprite/Mods/Silencer2.flip_h = true
		$Node2D/Sprite/Mods/Silencer2.position = Vector2(48,5)
		#$M4A1Sprite.flip_h = true
		#$M4A1Sprite.flip_v = true
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().get_root().add_child(bullet_instance)
		if (isShooting == false):
			#$Node2D/Sprite.flip_v = false
			#$Node2D/Sprite.flip_v = true
			$Node2D/Sprite/Mods/Silencer2.flip_h = true
			$Node2D/Sprite/Mods/Silencer2.position = Vector2(48,5)
	#Down
	if Global.player_direction == "2":
		bullet_speed = 500
		print('FIRE!')
		print(Global.player_direction)
		isShooting = true 
		bullet_instance.position = $Node2D/Sprite/Muzzle.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees + (270 / PI)
		#look_at(get_global_mouse_position())
		bullet_instance.apply_impulse(Vector2(), Vector2(0, bullet_speed).rotated(rotation))
		get_tree().get_root().add_child(bullet_instance)
	#Up
	if Global.player_direction == "3":
		bullet_speed = -500
		print('FIRE!')
		print(Global.player_direction)
		isShooting = true 
		bullet_instance.position = $Node2D/Sprite/Muzzle.get_global_position() + Vector2(0,0)
		bullet_instance.rotation_degrees = rotation_degrees + (-270 / PI)
		#look_at(get_global_mouse_position())
		bullet_instance.apply_impulse(Vector2(), Vector2(0, bullet_speed).rotated(rotation))
		get_tree().get_root().add_child(bullet_instance)
#Assault Rifle Animations
func _assault_Rifle_Animation():
	if parent_velocity != Vector2.ZERO:
		animationTree.set("parameters/IdleM4A1/blend_position", parent_velocity.normalized())
		animationState.travel("IdleM4A1")
		if isShooting:
			if Global.player_direction == "0":#right
				$AnimationPlayer.play("Shooting_M4A1-right")
			if Global.player_direction == "1":#left
				$AnimationPlayer.play("Shooting_M4A1-left")
			if Global.player_direction == "2":#down
				$AnimationPlayer.play("Shooting_M4A1-down")
			if Global.player_direction == "3":#up
				$AnimationPlayer.play("Shooting_M4A1-up")
			else:
				animationTree.set("parameters/IdleM4A1/blend_position", parent_velocity.normalized())
				animationState.travel("IdleM4A1")
# Old Animations
func _guns_animation():
	if parent_velocity != Vector2.ZERO:
		animationTree.set("parameters/IdleM4A1/blend_position", parent_velocity.normalized())
		animationState.travel("IdleM4A1")
		if isShooting:
				animationState.travel("Shooting")
				animationTree.set("parameters/Shooting/blend_position", parent_velocity.normalized())
		#Old code
		#else:
			#animationTree.set("parameters/IdleM4A1/blend_position", parent_velocity.normalized())
	#else:
		#animationState.travel("IdleM4A1")
		
# Toggle use of the laser sight
func toggle_lazer():
	#var player = playerPath.instance()
	var lazer_attachment = $Node2D/Sprite/Mods/LazerBeam# this one doesnt spamm cannot fine lazer beam
	
	#var lazer_attachment = get_node("Position2D/Weapons/M4A1/LazerBeam")#Old Code
	if Input.is_action_just_pressed("Lazer"):
		#if hasWeapon:
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


# Old Code
#func get_input() -> void:
#	# "ui_attack
#	if Input.is_action_just_pressed("fire") and not animation_player.is_playing():
#		animation_player.play("charge")
#	elif Input.is_action_just_released("fire"):
#		if animation_player.is_playing() and animation_player.current_animation == "fire":
#			animation_player.play("attack")
#
#func move(mouse_direction: Vector2):
#	if not animation_player.is_playing() or animation_player.current_animation == "charge":
#		rotation = mouse_direction.angle()
#		hitbox.knockback_direction = mouse_direction
#		if scale.y == 1 and mouse_direction.x < 0:
#			scale.y = -1
#		elif scale.y == -1 and mouse_direction.x > 0:
#			scale.y = 1
#func cancel_attack() -> void:
#	animation_player.play("cancel_attack")
	

#export(bool) var on_floor: bool = false
#
#var can_active_ability: bool = true
#
#func _on_PlayerDetector_body_entered(body):
#	if body != null:
#		body.pick_up_weapon(self)
#		position = Vector2.ZERO
#func get_texture() -> Texture:
#	return get_node("Node2D/Sprite").texture




