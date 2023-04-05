extends Node2D

onready var menu = $Menu
onready var high_score_label = get_node("%HighScore")
onready var play_button = get_node("%PlayButton")
onready var controls_button = get_node("%ControlsButton")
onready var title_music = $TitleMusic
onready var animation_player = $AnimationPlayer
onready var account_info_ui = $AccountInfo
onready var account_name_label = $AccountInfo/AccountName
onready var logout_button = $AccountInfo/LogoutButton

func _ready():
	# Default size 1280x720
	OS.window_size = Vector2(1280, 720)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

	high_score_label.set_text("High Score\n" + str(Globals.high_score))
	title_music.play()
	
	# Check if user already signed in
	var signed_in = _check_loopring_wallet_connected()
	# TODO: need a new UI to display multiple connected wallets
	var stacks_signed_in = _check_stacks_wallet_connected()
	print("Stacks wallet: " + StacksGlobals.wallet)
	if signed_in:
		account_name_label.text = "Signed in as:\n" + str(LoopringGlobals.wallet)
		account_info_ui.show()
	else:
		account_info_ui.hide()
		logout_button.disabled = true
		var null_path = NodePath()
		play_button.focus_neighbour_top = null_path
		play_button.focus_neighbour_right = null_path
		controls_button.focus_neighbour_right = null_path
		controls_button.focus_neighbour_bottom = null_path
	
	play_button.grab_focus()
	MetaBoyGlobals.set_selected_metaboy(MetaBoyGlobals.default_metaboy)

func _check_loopring_wallet_connected() -> bool:
	var user_config = ConfigFile.new()
	var err = user_config.load(LoopringGlobals.USER_DATA_SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print("No Loopring user data found.")
		return false
	elif err != OK:
		print("Error when attempting to load Loopring user data.")
		return false
	else:
		var account = user_config.get_value(LoopringGlobals.DATA_SECTION, "LoopringAccount", "")
		var wallet_type = user_config.get_value(LoopringGlobals.DATA_SECTION, "LoopringWalletType", -1)
		if account != null and account != "" and wallet_type != null and LoopringGlobals.is_valid_wallet_type(wallet_type):
			# Wallet account detected
			LoopringGlobals.wallet = account
			LoopringGlobals.set_wallet_type(wallet_type)
			return true
	
	return false

func _check_stacks_wallet_connected() -> bool:
	var user_config = ConfigFile.new()
	var err = user_config.load(StacksGlobals.USER_DATA_SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print("No Stacks user data found.")
		return false
	elif err != OK:
		print("Error when attempting to load Stacks user data.")
		return false
	else:
		var account = user_config.get_value(StacksGlobals.DATA_SECTION, "StacksAccount", "")
		var wallet_type = user_config.get_value(StacksGlobals.DATA_SECTION, "StacksWalletType", -1)
		if account != null and account != "" and wallet_type != null and StacksGlobals.is_valid_wallet_type(wallet_type):
			# Wallet account detected
			StacksGlobals.wallet = account
			StacksGlobals.set_wallet_type(wallet_type)
			return true
	
	return false

func _process(_delta):
	# Hacky fix for web build
	if not title_music.playing:
		title_music.play()
	
	var jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed:
		var focus_owner = menu.get_focus_owner()
		if focus_owner == play_button:
			_on_PlayButton_pressed()
		elif focus_owner == controls_button:
			_on_ControlsButton_pressed()

func _on_PlayButton_pressed():
	if not SceneManager.transition_running:
		animation_player.play("transition")
		SceneManager.switch_to_scene("res://UI/Screens/LoginScreen.tscn", true)

func _on_ControlsButton_pressed():
	if not SceneManager.transition_running:
		animation_player.play("transition")
		SceneManager.switch_to_scene("res://UI/Screens/ControlsScreen.tscn", true)

func _on_LogoutButton_pressed():
	if not SceneManager.transition_running:
		Loopring.logout()
		# TODO: logout should either clear data for both Loopring and Stacks, or let
		# the user logout each individually
		MetaBoyGlobals.clear_data()
		get_tree().reload_current_scene()
