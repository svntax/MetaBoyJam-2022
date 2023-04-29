extends Node2D

const MetaBoyDisplay = preload("res://MetaBoy/MetaBoyDisplay.tscn")

onready var tab_container = $UI/TabContainer

onready var metaboy_tab = $UI/TabContainer/MetaBoy
onready var metaboy_grid = get_node("%MetaBoyGrid")
onready var no_metaboy_label = get_node("%NoMetaBoyLabel")

onready var metaboy_stx_tab = get_node("UI/TabContainer/MetaBoy - First Odyssey")
onready var metaboy_stx_grid = get_node("%MetaBoySTXGrid")
onready var no_metaboy_stx_label = get_node("%NoMetaBoySTXLabel")

onready var loading_bg = $FrontLayer/LoadingBg
onready var loading_label = $FrontLayer/LoadingLabel

var account_object : Dictionary = {}
onready var num_metaboys = 0
onready var num_stx_metaboys = 0

func _ready():
	no_metaboy_label.hide()
	no_metaboy_stx_label.show()
	
	if not LoopringGlobals.wallet.empty():
		if MetaBoyGlobals.user_nfts_loopring.empty():
			# Attempt to fetch user's NFTs
			yield(get_loopring_account(), "completed")
			yield(get_metaboy_tokens(), "completed")
		else:
			_parse_metaboy_nfts(MetaBoyGlobals.user_nfts_loopring)
	
	if not StacksGlobals.wallet.empty():
		if MetaBoyGlobals.user_nfts_stacks.empty():
			# Attempt to fetch user's NFTs
			yield(get_stx_metaboy_tokens(), "completed")
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
	
	loading_bg.hide()
	loading_label.hide()
	
	_focus_first_grid_element()

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

func get_loopring_account() -> void:
	var json = Loopring.get_account_object(LoopringGlobals.wallet)
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	account_object = json.result

func get_metaboy_tokens() -> void:
	var token_address = MetaBoyGlobals.CONTRACT_OG
	var json = Loopring.get_token_balance(str(account_object.get("accountId")), Globals.loopring_api_key, token_address, false)
	
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
	if tokens.empty():
		return
	
	# Loop through each dictionary of attributes for each MetaBoy and set
	# the corresponding values.

	# Mapping from token address to ID is saved locally
	var metadata_mapping = null
	if MetaBoyGlobals.og_token_id_map_json.empty():
		metadata_mapping = MetaBoyGlobals.load_og_token_id_map_json()
		if metadata_mapping is GDScriptFunctionState:
			metadata_mapping = yield(metadata_mapping, "completed")
	else:
		metadata_mapping = MetaBoyGlobals.og_token_id_map_json
	
	# Metadata is saved locally
	var metadata = null
	if MetaBoyGlobals.og_metadata_json.empty():
		metadata = MetaBoyGlobals.load_og_metadata_json()
		if metadata is GDScriptFunctionState:
			metadata = yield(metadata, "completed")
	else:
		metadata = MetaBoyGlobals.og_metadata_json
	
	var first = true
	for token in tokens:
		# Read the NFT metadata
		var nft_id_address = token.get("nftId") # Hex address of NFT
		var nft_id = MetaBoyGlobals.get_og_id_from_token(nft_id_address)
		
		if nft_id == -1:
			# Not part of the collection
			continue
		elif MetaBoyGlobals.is_iconic_og(nft_id):
			# TODO: iconics are unique and must be handled differently
			continue
		
		if metadata != null and metadata_mapping != null: # TODO: add a refresh/retry button
			var formatted_name = "MetaBoy\n#"
			
			var nft_properties = {}
			var nft_json_obj = MetaBoyGlobals.get_og_metadata_for_token(nft_id_address)
			if !nft_json_obj.empty():
				if nft_json_obj.has("Id") and nft_json_obj.has("Traits"):
					formatted_name += str(nft_json_obj["Id"])
					var attributes : Array = nft_json_obj["Traits"]
					for attribute in attributes:
						var trait = attribute["TraitType"]
						var value = attribute["TraitValue"]
						nft_properties[trait] = value
					var metaboy_display = _add_metaboy_entry(formatted_name, nft_properties, MetaBoyGlobals.Collection.OG)
					if first:
						first = false
						metaboy_display.select()
					num_metaboys += 1

func get_stx_metaboy_tokens() -> void:
	var json = Stacks.get_account_balance(StacksGlobals.wallet)
	
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	
	var account_balance = json.result
	
	# Fetch the user's NFTs
	if account_balance.has("non_fungible_tokens"):
		var tokens : Dictionary = account_balance.get("non_fungible_tokens")
		MetaBoyGlobals.user_nfts_stacks = tokens
		
		if tokens.empty():
			# No STX MetaBoys found
			return
		
		_parse_stx_metaboy_nfts(tokens)
	else:
		# No STX MetaBoys found
		MetaBoyGlobals.user_nfts_stacks.clear()

func _parse_stx_metaboy_nfts(tokens: Dictionary) -> void:
	var token_address = MetaBoyGlobals.CONTRACT_STX
	var first = true
	for key in tokens:
		var collection_address = key.split(".")[0]
		if collection_address == token_address:
			var asset_identifiers = [key]
			var nft_holdings_json = Stacks.get_nft_holdings(StacksGlobals.wallet, asset_identifiers)
			if nft_holdings_json is GDScriptFunctionState:
				nft_holdings_json = yield(nft_holdings_json, "completed")
			var nft_holdings = nft_holdings_json.result
			if nft_holdings.has("results"):
				var nft_results : Array = nft_holdings.get("results")
				for nft in nft_results:
					var nft_id = nft.get("value").get("repr")
					# NFT ID is an unsigned int, so it starts with "u"
					nft_id = str(nft_id).substr(1)
					# Metadata is saved locally
					var metadata = null
					if MetaBoyGlobals.stx_metadata_json.empty():
						metadata = MetaBoyGlobals.load_stx_metadata_json()
						if metadata is GDScriptFunctionState:
							metadata = yield(metadata, "completed")
					else:
						metadata = MetaBoyGlobals.stx_metadata_json
					if metadata != null:
						var formatted_name = "MetaBoy\n#" + nft_id
						
						var nft_properties = {}
						var nft_json_obj = MetaBoyGlobals.get_stx_metadata_for_id(int(nft_id))
						if !nft_json_obj.empty():
							var attributes : Array = nft_json_obj["attributes"]
							for attribute in attributes:
								var trait = attribute["trait"]
								var value = attribute["value"]
								nft_properties[trait] = value
							var metaboy_display = _add_metaboy_entry(formatted_name, nft_properties, MetaBoyGlobals.Collection.STX)
							if first:
								first = false
								metaboy_display.select()
							num_stx_metaboys += 1
	
	# Update the STX label here so that the label doesn't check the count before
	# the metadata reading is complete.
	if num_stx_metaboys > 0:
		no_metaboy_stx_label.queue_free()
	else:
		no_metaboy_stx_label.show()
	
	_focus_first_grid_element()

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
	_focus_first_grid_element()

func _focus_first_grid_element() -> void:
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
