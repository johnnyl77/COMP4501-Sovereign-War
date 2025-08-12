extends Control

var isfree

# Audio Busses
const AUDIO_BUS_MASTER = 0          # Master is always index 0
const AUDIO_BUS_MUSIC = 1           # Music bus
const AUDIO_BUS_SFX = 2             # SFX bus
const AUDIO_BUS_UI = 3              # UI bus

const audio_ticks = 9               # Total audio range options (0-9 ticks)
var settings_is_setup = false       # Whether or not settings have been initialized yet
var normalized_master_vol           # Normalized master volume

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_start_game_button_button_down() -> void:
	script.isfree = false
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_free_mode_button_button_down() -> void:
	script.isfree = true
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_instructions_button_button_down() -> void:
	$PauseMenuC.visible = false
	$PauseMenuC3.visible = true

func _on_settings_button_button_down() -> void:
	$PauseMenuC.visible = false
	$PauseMenuC4.visible = true
	
	if not settings_is_setup:
		setup_settings()
	

func setup_settings() -> void:
	# Audio Setup
	$Control/AudioStreamPlayer2D.bus = "Music"
	$PauseMenuC4/BoxContainer/master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AUDIO_BUS_MASTER))
	$PauseMenuC4/BoxContainer/music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AUDIO_BUS_MUSIC))
	$PauseMenuC4/BoxContainer/sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AUDIO_BUS_SFX))
	$PauseMenuC4/BoxContainer/ui_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AUDIO_BUS_UI))
	normalized_master_vol = $PauseMenuC4/BoxContainer/music_volume_slider.value / audio_ticks
	
	settings_is_setup = true

func _on_quit_button_button_down() -> void:
	get_tree().quit()

func _on_back_button_button_down() -> void:
	$PauseMenuC.visible = true
	$PauseMenuC3.visible = false
	$PauseMenuC4.visible = false

func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_MASTER, linear_to_db(value))
	
func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, linear_to_db(value))
	
func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_SFX, linear_to_db(value))
	
func _on_ui_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_UI, linear_to_db(value))
