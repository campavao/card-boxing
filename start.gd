extends CanvasLayer

func _on_start_pressed():
	hide()
	NetworkManager.become_host()
	$"../UI".show()

	

func _on_join_pressed():
	hide()
	NetworkManager.join_game()
	$"../UI".show()
