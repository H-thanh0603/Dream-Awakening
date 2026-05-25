extends Node
##
## AudioManager — play SFX/music qua bus Master/Music/SFX/UI.
## Contract: GDD §C.10
## Phase 0: skeleton. Phase 5 T5.2 implement đầy đủ với asset.
##

func _ready() -> void:
	print("[AudioManager] ready")

func play_sfx(sfx_id: String) -> void:
	pass

func play_music(music_id: String, fade_in: float = 1.0) -> void:
	pass

func stop_music(fade_out: float = 1.0) -> void:
	pass

func set_volume(bus: String, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(value))
