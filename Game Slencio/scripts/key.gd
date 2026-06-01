extends Area2D

var collected := false

func _process(_delta):
	if collected:
		return
	
	for player in get_tree().get_nodes_in_group("player"):
		var dist = player.global_position.distance_to(global_position)
		# Debug — mostra distância no console
		if dist < 150.0:
			print("Player perto da chave! Distância: ", dist)
			print("Pressione E (P1) ou Enter Numpad (P2) para pegar")
		
		if dist > 80.0:
			continue
		
		var action = "p2_hide" if player.is_in_group("p2") else "hide"
		if Input.is_action_just_pressed(action):
			_collect()
			return

func _collect():
	collected = true
	print("CHAVE COLETADA!")
	get_tree().call_group("game_manager", "key_collected")
	queue_free()
