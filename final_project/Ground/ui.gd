extends Control

var GREEN = Color(0, 1, 0)
var GRAY = Color(0.5,0.5,0.5)
var isInUI = false
var building_script
var current_action = 0 # 0, 1, 2 spawn units, build, destroy


var FARMER_COST = 10
var MINER_COST = 10
var LUMBER_COST = 10
var KNIGHT_COST = 50
var MACE_COST = 75
var MAGE_COST = 200

var FARM_COST = 25
var HOUSE_COST = 50
var BARRACK_COST = 100
var SPIKE_COST = 100
var WALL_COST = 50
var XBOW_COST = 200
var doOnce = true

var unit_label_names = ["farmer_cost_label", "lumber_cost_label", "miner_cost_label", "knight_cost_label", "mace_cost_label", "mage_cost_label"]
var building_label_names = ["farm_cost_label", "mine_cost_label", "barrack_cost_label", "spike_cost_label", "wall_cost_label", "xbow_cost_label"]
var action_label_names = ["SPAWN UNITS", "BUILDING MODE", "DESTROY MODE"]

var fade_tween: Tween
var initial_fade_lifetime: float = 5.0
var fade_lifetime: float = 1.5            # Delayed time before the fading effect starts happening
var fade_duration: float = 2.0            # Duration that a label fades
var is_paused = false
var tooltips_enabled = true

func end_game(win):
	if(doOnce):
		doOnce = false
		if(win == false):
			$WINMENU/BoxContainer/WINB.text = "FALSE"
		$WINMENU.visible = true
		$PauseMenuC2.visible = false
		$ResourcesC.visible = false
		$PauseC.visible = false
		$UnitsC.visible = false
		$ActionsC.visible = false
		$BuildingsC.visible = false
		$TooltipsC.visible = false
		$PauseMenuC.visible = false
		$PauseMenuC2.visible = false
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://menu_level.tscn")
	
	
func _ready() -> void:
	building_script = get_node("../Player/BuildingManager")
	#$UnitCostsC/BoxContainer/farmer_cost_label = ""
	
	# Fading Initial Labels 
	await get_tree().create_timer(initial_fade_lifetime).timeout
	fade_all_labels()



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("one_key"):
		change_action_mode(0)
		fade_action_label()
		pass
	if Input.is_action_just_pressed("two_key"):
		change_action_mode(1)
		fade_action_label()
		pass
	if Input.is_action_just_pressed("three_key"):
		change_action_mode(2)
		fade_action_label()
		pass
	
	if not is_paused:
		$TooltipsC.visible = tooltips_enabled
	else:
		$TooltipsC.visible = false



func toggle_hover(x : bool, y : String, resource : String, amount : int,isBuilding : bool):
	$Control/AudioStreamPlayer2D2.play()
	var node = get_node(y)
	var grayzone = max(node.modulate.g,node.modulate.r)
	
	if(x):
		if(resource != "NULL"):
			if($"../Player".can_buy(resource,amount,isBuilding)):
				node.modulate = Color(0, grayzone, 0)
			else:
				node.modulate = Color(grayzone, 0, 0)
		else:
			node.modulate = Color(0, grayzone, 0)
		
		if current_action == 0:
			hide_unit_costs()
			
			# Show current cost label
			var label_name = y.split("/")[-1].replace("_button", "_cost_label")
			if label_name in unit_label_names:
				var label = $UnitCostsC/BoxContainer.get_node(label_name)
				label.modulate.a = 1.0
				
				# Changes font color of cost labels when hovering over them
				if resource != "NULL" and $"../Player".can_buy(resource, amount, isBuilding):
					print(label_name, resource, amount)
					label.modulate = Color(1,1,1)
				else:
					print(label_name, resource, amount)
					label.modulate = Color(0.8, 0, 0)
		elif current_action == 1:
			hide_building_costs()
			
			var label_name = y.split("/")[-1].replace("_button", "_cost_label")
			if label_name in building_label_names:
				var label = $BuildingCostsC/BoxContainer.get_node(label_name)
				label.modulate.a = 1.0
				
				# Changes font color of cost labels when hovering over them
				if resource != "NULL" and $"../Player".can_buy(resource, amount, isBuilding):
					print(label_name, resource, amount)
					label.modulate = Color(1,1,1)
				else:
					print(label_name, resource, amount)
					label.modulate = Color(0.8, 0, 0)
	else:
		node.modulate = Color(grayzone, grayzone, grayzone)
		hide_unit_costs()
		hide_building_costs()
	pass


func setBuildButtonsGray() -> void:
	$BuildingsC/BoxContainer/farm_button.modulate = Color(0.75, 0.75, 0.75)
	$BuildingsC/BoxContainer/mine_button.modulate = Color(0.75, 0.75, 0.75)
	$BuildingsC/BoxContainer/barrack_button.modulate = Color(0.75, 0.75, 0.75)
	$BuildingsC/BoxContainer/spike_button.modulate = Color(0.75, 0.75, 0.75)
	$BuildingsC/BoxContainer/wall_button.modulate = Color(0.75, 0.75, 0.75)
	$BuildingsC/BoxContainer/xbow_button.modulate = Color(0.75, 0.75, 0.75)


func switch_building(x : int):
	building_script.switch_building(x)
	var arr = [$BuildingsC/BoxContainer/farm_button,$BuildingsC/BoxContainer/mine_button,$BuildingsC/BoxContainer/barrack_button,$BuildingsC/BoxContainer/spike_button,$BuildingsC/BoxContainer/wall_button,$BuildingsC/BoxContainer/xbow_button]
	setBuildButtonsGray()
	arr[x].modulate = Color(1, 1, 1)
	pass


func hide_unit_costs() -> void:
	for label in $UnitCostsC/BoxContainer.get_children():
		label.modulate.a = 0.0


func hide_building_costs() -> void:
	for label in $BuildingCostsC/BoxContainer.get_children():
		label.modulate.a = 0.0


func toggleIsInUI(x: bool):
	isInUI = x





func _on_mouse_entered() -> void:
	toggleIsInUI(false)



func _on_mouse_exited() -> void:
	toggleIsInUI(true)



func _on_farm_button_button_down() -> void:
	switch_building(0)



func _on_mine_button_button_down() -> void:
	switch_building(1)


func _on_barrack_button_button_down() -> void:
	switch_building(2)


func _on_spike_button_button_down() -> void:
	switch_building(3)


func _on_wall_button_button_down() -> void:
	switch_building(4)


func _on_xbow_button_button_down() -> void:
	switch_building(5)


func _on_farm_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/farm_button","food",FARM_COST,true)


func _on_farm_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/farm_button","NULL",0,true)


func _on_mine_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/mine_button","wood",HOUSE_COST,true)


func _on_mine_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/mine_button","NULL",0,true)


func _on_barrack_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/barrack_button","wood",BARRACK_COST,true)


func _on_barrack_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/barrack_button","NULL",0,true)


func _on_spike_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/spike_button","ore",SPIKE_COST,true)


func _on_spike_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/spike_button","NULL",0,true)


func _on_wall_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/wall_button","ore",WALL_COST,true)


func _on_wall_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/wall_button","NULL",0,true)


func _on_xbow_button_mouse_entered() -> void:
	toggle_hover(true,"BuildingsC/BoxContainer/xbow_button","ore",XBOW_COST,true)


func _on_xbow_button_mouse_exited() -> void:
	toggle_hover(false,"BuildingsC/BoxContainer/xbow_button","NULL",0,true)


func _on_pause_button_mouse_entered() -> void:
	toggle_hover(true,"PauseC/BoxContainer/pause_button","NULL",0,true)

func _on_pause_button_mouse_exited() -> void:
	toggle_hover(false,"PauseC/BoxContainer/pause_button","NULL",0,true)


func _on_defend_button_mouse_entered() -> void:
	toggle_hover(true,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/defend_button","NULL",0,true)


func _on_defend_button_mouse_exited() -> void:
	toggle_hover(false,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/defend_button","NULL",0,true)


func _on_attack_button_mouse_entered() -> void:
	toggle_hover(true,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/attack_button","NULL",0,true)


func _on_attack_button_mouse_exited() -> void:
	toggle_hover(false,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/attack_button","NULL",0,true)

func _on_action_button_mouse_entered() -> void:
	toggle_hover(true,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/action_button","NULL",0,true)


func _on_action_button_mouse_exited() -> void:
	toggle_hover(false,"ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/action_button","NULL",0,true)

func change_action_mode(x : int):
	building_script.enterDeleteMode()
	current_action = x
	building_script.updatePreview()
	if(x == 0):
		$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/action_button.texture_normal = preload("res://Ground/minions.png")
		$UnitsC.visible = true
		$BuildingsC.visible = false
		
	if(x == 1):
		$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/action_button.texture_normal = preload("res://Ground/hammer-nails.png")
		$UnitsC.visible = false
		$BuildingsC.visible = true
	if(x == 2):
		$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/action_button.texture_normal = preload("res://Textures/Icons/hammer-break.png")
		$UnitsC.visible = false
		$BuildingsC.visible = false
	pass
	

func _on_action_button_button_down() -> void:
	current_action += 1
	if(current_action > 2):
		current_action = 0
	change_action_mode(current_action)
	
	fade_action_label()

func clear_previous_label():
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/fading_label.modulate.a = 0.0
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/fading_label.modulate.a = 0.0
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/fading_label.modulate.a = 0.0
	if fade_tween:
		fade_tween.kill()

func spawn_unit_clicked(unit,amount):
	if($"../Player".can_buy("food",amount,false)):
		$"../Player".consume_resouce("food",amount)
		$"../Player/UnitManager".spawn_unit(unit,0)




func update_ui_text(food: int, wood: int, ore: int, units: int, health: int, enemy_health: int, max_units) -> void:
	var max_value = 500
	var max_digits = 3

	$ResourcesC/BoxContainer/food_text.text = str(food)
	$ResourcesC/BoxContainer/wood_text.text = str(wood)
	$ResourcesC/BoxContainer/ore_text.text = str(ore)
	$ResourcesC/BoxContainer/units_text.text = str(units)
	$ResourcesC/BoxContainer/health_text.text = str(health)
	$ResourcesC/BoxContainer/enemy_text.text = str(enemy_health)
	$ResourcesC/BoxContainer/food_text5.text = "/ " + str(max_units)
func _on_farmer_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/farmer_button","food",FARMER_COST,false)



func _on_farmer_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/farmer_button","NULL",0,false)



func _on_lumber_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/lumber_button","food",LUMBER_COST,false)


func _on_lumber_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/lumber_button","NULL",0,false)


func _on_miner_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/miner_button","food",MINER_COST,false)


func _on_miner_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/miner_button","NULL",0,false)


func _on_knight_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/knight_button","food",KNIGHT_COST,false)


func _on_knight_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/knight_button","NULL",0,false)


func _on_mace_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/mace_button","food",MACE_COST,false)


func _on_mace_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/mace_button","NULL",0,false)


func _on_mage_button_mouse_entered() -> void:
	toggle_hover(true,"UnitsC/BoxContainer/mage_button","food",MAGE_COST,false)


func _on_mage_button_mouse_exited() -> void:
	toggle_hover(false,"UnitsC/BoxContainer/mage_button","NULL",0,false)


func _on_farmer_button_button_down() -> void:
	spawn_unit_clicked(0,FARMER_COST)


func _on_lumber_button_button_down() -> void:
	spawn_unit_clicked(1,LUMBER_COST)
	


func _on_miner_button_button_down() -> void:
	
	spawn_unit_clicked(2,MINER_COST)


func _on_knight_button_button_down() -> void:
	spawn_unit_clicked(3,KNIGHT_COST)


func _on_mace_button_button_down() -> void:
	spawn_unit_clicked(4,MACE_COST)


func _on_mage_button_button_down() -> void:
	spawn_unit_clicked(5,MAGE_COST)


func _on_pause_button_button_down() -> void:
	hide_all_uis()
	$PauseMenuC.visible = true
	is_paused = true
	
func hide_all_uis():
	$ResourcesC.visible = false
	$PauseC.visible = false
	$UnitsC.visible = false
	$ActionsC.visible = false
	$BuildingsC.visible = false
	$TooltipsC.visible = false
	$PauseMenuC.visible = false

func show_all_uis():
	$ResourcesC.visible = true
	$PauseC.visible = true
	$ActionsC.visible = true
	$TooltipsC.visible = true
	$PauseMenuC.visible = true
	change_action_mode(current_action)

func _on_resume_button_button_down() -> void:
	show_all_uis()
	
	change_action_mode(current_action)
	
	$PauseMenuC.visible = false
	is_paused = false


func _on_defend_button_button_down() -> void:
	$"../Player".attack_mode_clicked(0)
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/defend_button.modulate = Color(1, 1, 1)
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/attack_button.modulate = Color(0.75, 0.75, 0.75)
	
	clear_previous_label()
	show_fading_label("DEFEND", $ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/fading_label)


func _on_attack_button_button_down() -> void:
	$"../Player".attack_mode_clicked(1)
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/defend_button.modulate = Color(0.75, 0.75, 0.75)
	$ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/attack_button.modulate = Color(1, 1, 1)
	
	clear_previous_label()
	show_fading_label("ATTACK", $ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/fading_label)


func _on_return_to_menu_button_button_down() -> void:
	get_tree().change_scene_to_file("res://menu_level.tscn")


func _on_settings_button_button_down() -> void:
	$PauseMenuC.visible = false
	$SettingsMenuC.visible = true
	#get_tree().quit()
	pass

func _on_quit_button_button_down() -> void:
	get_tree().quit()


func playPlaceSound(destroy):
	if(destroy == true):
		$Control/AudioStreamPlayer2D4.play()
	else:
		$Control/AudioStreamPlayer2D3.play()


func _on_audio_stream_player_2d_finished() -> void:
	$Control/AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.1)



func _on_audio_stream_player_2d_2_finished() -> void:
	$Control/AudioStreamPlayer2D2.pitch_scale = randf_range(0.8, 1.1)



func _on_audio_stream_player_2d_3_finished() -> void:
	$Control/AudioStreamPlayer2D3.pitch_scale = randf_range(0.8, 1.1)



func _on_audio_stream_player_2d_4_finished() -> void:
	$Control/AudioStreamPlayer2D4.pitch_scale = randf_range(0.8, 1.1)


func _on_back_button_button_down() -> void:
	$PauseMenuC.visible = true
	$SettingsMenuC.visible = false


func _on_drag_sens_slider_value_changed(value: float) -> void:
	$"../Player".set_move_speed(value)


func _on_zoom_sens_slider_value_changed(value: float) -> void:
	$"../Player".set_zoom_speed(value)


func _on_check_box_toggled(toggled_on: bool) -> void:
	tooltips_enabled = toggled_on

func fade_all_labels() -> void:
	var tween = create_tween()
	tween.tween_interval(fade_lifetime)
	tween.tween_property($ActionsC/HBoxContainer/VBoxContainer/HBoxContainer/fading_label, "modulate:a", 0.0, fade_duration)
	tween.parallel().tween_property($ActionsC/HBoxContainer/VBoxContainer/HBoxContainer2/fading_label, "modulate:a", 0.0, fade_duration)
	tween.parallel().tween_property($ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/fading_label, "modulate:a", 0.0, fade_duration)

func fade_action_label() -> void:
	clear_previous_label()
	show_fading_label(action_label_names[current_action], $ActionsC/HBoxContainer/VBoxContainer/HBoxContainer3/fading_label)

func show_fading_label(text: String, label: Label) -> void:
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	label.text = text
	label.modulate.a = 1.0
	
	fade_tween.tween_interval(fade_lifetime)
	fade_tween.tween_property(label, "modulate:a", 0.0, fade_duration)

func _on_master_volume_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
