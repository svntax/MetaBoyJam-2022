extends Node2D

const MetaBoyDisplay = preload("res://MetaBoy/MetaBoyDisplay.tscn")

onready var tab_container = $UI/TabContainer
onready var metaboy_tab = $UI/TabContainer/MetaBoy
onready var metaboy_grid = get_node("%MetaBoyGrid")
onready var no_metaboy_label = get_node("%NoMetaBoyLabel")

# An array of dictionaries, where each dictionary contains data on a specific MetaBoy
var metaboy_list = []

func _ready():
	# TODO: testing purposes only
	for i in range(14):
		metaboy_list.append(MetaBoyGlobals.get_random_attributes())
	
	if metaboy_list.empty():
		pass
	else:
		no_metaboy_label.queue_free()
		# Loop through each dictionary of attributes for each MetaBoy and set
		# the corresponding values.
		var first = true
		for metaboy in metaboy_list:
			var metaboy_display = MetaBoyDisplay.instance()
			metaboy_grid.add_child(metaboy_display)
			metaboy_display.set_metaboy_name("MetaBoy\n#abcd")
			metaboy_display.set_metaboy_attributes(metaboy)
			metaboy_display.connect("metaboy_selected", self, "_on_metaboy_selected")
			if first:
				first = false
				metaboy_display.select()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.switch_to_scene("res://UI/Screens/TitleScreen.tscn", true)
	
	var tab_changed = false
	if Input.is_action_just_pressed("ui_focus_next"):
		if tab_container.current_tab < tab_container.get_tab_count() - 1:
			tab_container.current_tab += 1
			tab_changed = true
	if Input.is_action_just_pressed("ui_focus_prev"):
		if tab_container.current_tab > 0:
			tab_container.current_tab -= 1
			tab_changed = true
	
	# Focus on the first element in the grid after switching tabs.
	if tab_changed:
		if tab_container.get_current_tab_control() == metaboy_tab and \
				metaboy_grid.get_child_count() > 0:
			metaboy_grid.get_child(0).select()

func _on_metaboy_selected(attributes: Dictionary) -> void:
	if SceneManager.transition_running:
		return
	
	MetaBoyGlobals.set_selected_metaboy(attributes)
	get_tree().change_scene("res://UI/Screens/PlaySelectScreen.tscn")
