extends Node2D

const MetaBoyDisplay = preload("res://MetaBoy/MetaBoyDisplay.tscn")

onready var tab_container = $UI/TabContainer

onready var metaboy_tab = $UI/TabContainer/MetaBoy
onready var metaboy_grid = get_node("%MetaBoyGrid")
onready var no_metaboy_label = get_node("%NoMetaBoyLabel")

# TODO: fetch STX MetaBoys
onready var metaboy_stx_tab = get_node("UI/TabContainer/MetaBoy - First Odyssey")
onready var metaboy_stx_grid = get_node("%MetaBoySTXGrid")
onready var no_metaboy_stx_label = get_node("%NoMetaBoySTXLabel")

onready var loading_bg = $FrontLayer/LoadingBg
onready var loading_label = $FrontLayer/LoadingLabel

var account_object : Dictionary = {}
var num_metaboys = 0
var num_stx_metaboys = 0

func _ready():
	no_metaboy_label.hide()
	no_metaboy_stx_label.hide()
	
	if MetaBoyGlobals.user_nfts_loopring.empty():
		# Attempt to fetch user's NFTs
		yield(get_account(), "completed")
		yield(get_metaboy_tokens(), "completed")
	else:
		_parse_metaboy_nfts(MetaBoyGlobals.user_nfts_loopring)
	
	# TODO: Fetch STX MetaBoys
	if MetaBoyGlobals.user_nfts_stacks.empty():
		# Attempt to fetch user's NFTs
		pass
	else:
		_parse_stx_metaboy_nfts(MetaBoyGlobals.user_nfts_stacks)
	
	# TODO: testing purposes only
#	for i in range(5):
#		num_metaboys += 1
#		_add_metaboy_entry("Random\nMetaBoy", MetaBoyGlobals.get_random_attributes(), MetaBoyGlobals.Collection.OG)
#	for i in range(5):
#		num_stx_metaboys += 1
#		var random_attributes = MetaBoyGlobals.get_random_attributes(MetaBoyGlobals.Collection.STX)
#		_add_metaboy_entry("Random\nSTX MetaBoy", random_attributes, MetaBoyGlobals.Collection.STX)
	
	if num_metaboys == 0:
		no_metaboy_label.show()
	else:
		no_metaboy_label.queue_free()
	
	if num_stx_metaboys == 0:
		no_metaboy_stx_label.show()
	else:
		no_metaboy_stx_label.queue_free()
	
	loading_bg.hide()
	loading_label.hide()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://UI/Screens/LoginScreen.tscn")
	
	if loading_bg.visible:
		# No navigation handling while loading data
		return
	
	if Input.is_action_just_pressed("ui_focus_prev"):
		if tab_container.current_tab > 0:
			tab_container.current_tab -= 1
	elif Input.is_action_just_pressed("ui_focus_next"):
		if tab_container.current_tab < tab_container.get_tab_count() - 1:
			tab_container.current_tab += 1

func _on_metaboy_selected(attributes: Dictionary) -> void:
	if SceneManager.transition_running:
		return
	
	MetaBoyGlobals.set_selected_metaboy(attributes)
	get_tree().change_scene("res://UI/Screens/PlaySelectScreen.tscn")

func get_account() -> void:
	var json = Loopring.get_account_object(LoopringGlobals.wallet)
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	account_object = json.result

func get_metaboy_tokens() -> void:
	var token_address = MetaBoyGlobals.CONTRACT_OG
	var json = Loopring.get_token_balance(str(account_object.get("accountId")), Globals.loopring_api_key, token_address, true)
	
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	
	var response_object = json.result
	if response_object.has("data"):
		var tokens : Array = response_object.get("data")
		MetaBoyGlobals.user_nfts_loopring = tokens
		
		if tokens.empty():
			# No MetaBoys found
			return
		
		_parse_metaboy_nfts(tokens)
	else:
		# No MetaBoys found
		MetaBoyGlobals.user_nfts_loopring = []

func _parse_metaboy_nfts(tokens: Array) -> void:
	# Loop through each dictionary of attributes for each MetaBoy and set
	# the corresponding values.
	var first = true
	for token in tokens:
		# Read the NFT metadata
		var metadata = token.get("metadata")
		var nft_name = metadata.get("base").get("name")
		
		var nft_properties_json = JSON.parse(metadata.get("base").get("properties"))
		if nft_properties_json.error == OK:
			var nft_properties = nft_properties_json.result
			if nft_properties and !nft_properties.empty():
				# Assuming names are "MetaBoy #xxxx"
				var formatted_name = nft_name.replace(" ", "\n")
				var metaboy_display = _add_metaboy_entry(formatted_name, nft_properties, MetaBoyGlobals.Collection.OG)
				if first:
					first = false
					metaboy_display.select()
				num_metaboys += 1
			else:
				# No attributes found
				pass
		else:
			printerr("Failed to parse token attributes.")

func _parse_stx_metaboy_nfts(tokens: Array) -> void:
	# TODO
	pass

func _add_metaboy_entry(mb_name: String, mb_attributes: Dictionary, collection: int) -> Control:
	var metaboy_display = MetaBoyDisplay.instance()
	if collection == MetaBoyGlobals.Collection.OG:
		metaboy_grid.add_child(metaboy_display)
	elif collection == MetaBoyGlobals.Collection.STX:
		metaboy_stx_grid.add_child(metaboy_display)
	metaboy_display.set_metaboy_name(mb_name)
	metaboy_display.set_metaboy_attributes(mb_attributes, collection)
	metaboy_display.connect("metaboy_selected", self, "_on_metaboy_selected")
	return metaboy_display


func _on_TabContainer_tab_changed(tab):
	# Focus on the first element in the grid after switching tabs.
	if tab_container.get_current_tab_control() == metaboy_tab and \
			metaboy_grid.get_child_count() > 0:
		for entry in metaboy_grid.get_children():
			if entry.has_method("select"):
				entry.select()
				break
	if tab_container.get_current_tab_control() == metaboy_stx_tab and \
			metaboy_stx_grid.get_child_count() > 0:
		for entry in metaboy_stx_grid.get_children():
			if entry.has_method("select"):
				entry.select()
				break
