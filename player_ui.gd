extends Control

@onready var ship_name				= $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer/Ship_name"
@onready var space					= $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer2/Space"
@onready var ftl_cooldown			= $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer3/Cooldown_FTL"

@onready var scout_values			= $"MarginContainer/TabContainer/Unit status/Values/ScoutContainer/VBoxContainer"
@onready var troop_values			= $"MarginContainer/TabContainer/Unit status/Values/TroopContainer/VBoxContainer"
@onready var negotiator_values			= $"MarginContainer/TabContainer/Unit status/Values/NegotiatorContainer/VBoxContainer"
@onready var colony_values			= $"MarginContainer/TabContainer/Unit status/Values/ColonyContainer/VBoxContainer"

@onready var scout_upgrade			= $"MarginContainer/TabContainer/R&D/ScoutUpgrade"
@onready var troop_upgrade			= $"MarginContainer/TabContainer/R&D/TroopUpgrade2"
@onready var negotiator_upgrade		= $"MarginContainer/TabContainer/R&D/NegotiatorUpgrade3"
@onready var colony_upgrade			= $"MarginContainer/TabContainer/R&D/ColonyUpgrade4"

@onready var scout_exp				= $"MarginContainer/TabContainer/Unit status/Values/ScoutContainer/VBoxContainer/MarginContainer4/ProgressBar"
@onready var troop_exp				= $"MarginContainer/TabContainer/Unit status/Values/TroopContainer/VBoxContainer/MarginContainer4/ProgressBar"
@onready var negotiator_exp			= $"MarginContainer/TabContainer/Unit status/Values/NegotiatorContainer/VBoxContainer/MarginContainer4/ProgressBar"
@onready var colony_exp				= $"MarginContainer/TabContainer/Unit status/Values/ColonyContainer/VBoxContainer/MarginContainer4/ProgressBar"

@onready var scout_cooldown			= $"Unit Cooldown/Cooldown/ScoutContainer/cooldown_unit"
@onready var troop_cooldown			= $"Unit Cooldown/Cooldown/TroopContainer/cooldown_unit"
@onready var negotiator_cooldown	= $"Unit Cooldown/Cooldown/NegotiatorContainer/cooldown_unit"
@onready var colony_cooldown		= $"Unit Cooldown/Cooldown/ColonyContainer/cooldown_unit"

@onready var playerGlobalResources	= $PlayerGlobalResources
@onready var anim_player			= $AnimationPlayer
@onready var tooltip				= $Tooltip

var mainScene

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)
	_build_research_tab()
	_build_investment_tab()
	_build_module_list()

#SHIP STATUS TAB
func _on_ship_name_text_submitted(new_text: String) -> void:
	ship_name.text = new_text
	mainScene.player.fleet.fleet_params["fleet_name"] = new_text
	mainScene.player.fleet.set_fleet_name()
	mainScene.rename("Fleet", new_text)

#UNIT STATUS TAB
func _on_troop_unit_text_submitted(new_text: String) -> void:
	troop_values.get_node("MarginContainer/Troop_Unit").text = new_text
	mainScene.player.fleet.troop.unit_params["unit_name"] = new_text
	mainScene.rename("Troop", new_text)

func _on_negotiator_unit_text_submitted(new_text: String) -> void:
	negotiator_values.get_node("MarginContainer/Negotiator_Unit").text = new_text
	mainScene.player.fleet.negotiator.unit_params["unit_name"] = new_text
	mainScene.rename("Negotiator", new_text)

func _on_colony_unit_text_submitted(new_text: String) -> void:
	colony_values.get_node("MarginContainer/Colony_Unit").text = new_text
	mainScene.player.fleet.colony.unit_params["unit_name"] = new_text
	mainScene.rename("Colony", new_text)

func _on_scout_unit_text_submitted(new_text: String) -> void:
	scout_values.get_node("MarginContainer/Scout_Unit").text = new_text
	mainScene.player.fleet.scout.unit_params["unit_name"] = new_text
	mainScene.rename("Scout", new_text)

func _update_unit_values(unit_value):
	match unit_value["unit_type"] :
		0 :	#Troop
			troop_values.get_node("MarginContainer/Troop_Unit").text = unit_value["unit_name"]
			troop_values.get_node("MarginContainer2/Troop_Upgrade").text = "Lvl." + str(unit_value.get("level", 0))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				troop_values.get_node("MarginContainer3/Troop_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				troop_values.get_node("MarginContainer3/Troop_position").text = unit_value["unit_position"]
		1 :	#Negotiator
			negotiator_values.get_node("MarginContainer/Negotiator_Unit").text = unit_value["unit_name"]
			negotiator_values.get_node("MarginContainer2/Negotiator_Upgrade").text = "Lvl." + str(unit_value.get("level", 0))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				negotiator_values.get_node("MarginContainer3/Negotiator_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				negotiator_values.get_node("MarginContainer3/Negotiator_position").text = unit_value["unit_position"]
		2 :	#Scout
			scout_values.get_node("MarginContainer/Scout_Unit").text = unit_value["unit_name"]
			scout_values.get_node("MarginContainer2/Scout_Upgrade").text = "Lvl." + str(unit_value.get("level", 0))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				scout_values.get_node("MarginContainer3/Scout_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				scout_values.get_node("MarginContainer3/Scout_position").text = unit_value["unit_position"]
		3 :	#Colony
			colony_values.get_node("MarginContainer/Colony_Unit").text = unit_value["unit_name"]
			colony_values.get_node("MarginContainer2/Colony_Upgrade").text = "Lvl." + str(unit_value.get("level", 0))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				colony_values.get_node("MarginContainer3/Colony_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				colony_values.get_node("MarginContainer3/Colony_position").text = unit_value["unit_position"]
	update_unit_exp(unit_value)

## XP bar shows progress inside the current level (each level needs more XP).
func update_unit_exp(unit_value):
	var bar
	match unit_value["unit_type"] :
		0 :	bar = troop_exp
		1 :	bar = negotiator_exp
		2 :	bar = scout_exp
		3 :	bar = colony_exp
	bar.max_value = unit_value.get("exp_needed", 5)
	bar.value = unit_value.get("exp_progress", 0)

#R&D TAB
#func _update_upgrade_values(unit_value):
	#match unit_value["unit_type"] :
		#0 : #Troop
			#troop_upgrade._init_stat()
		#1 : #Negotiator
			#negotiator_upgrade._init_stat()
		#2 : # Scout
			#scout_upgrade._init_stat()
		#3 : #Colony
			#colony_upgrade._init_stat()

#func _init_upgrade():
	#scout_upgrade.unit = mainScene.player.fleet.scout
	#troop_upgrade.unit = mainScene.player.fleet.troop
	#negotiator_upgrade.unit = mainScene.player.fleet.negotiator
	#colony_upgrade.unit = mainScene.player.fleet.colony
	
func _update_PGR():
	playerGlobalResources.CoreUnit.text = str(mainScene.player.fleet.fleet_params["CoreUnit"])
	mainScene.prt.coreUnitCount.text = str(mainScene.player.fleet.fleet_params["CoreUnit"])
	# Space = module slots (see update_modules)

func _init_cooldown():
	ftl_cooldown.fleet = mainScene.player.fleet
	scout_cooldown.unit = mainScene.player.fleet.scout
	troop_cooldown.unit = mainScene.player.fleet.troop
	negotiator_cooldown.unit = mainScene.player.fleet.negotiator
	colony_cooldown.unit = mainScene.player.fleet.colony
	ftl_cooldown.server_offset = mainScene.player.fleet.server_offset
	scout_cooldown.server_offset = mainScene.player.fleet.server_offset
	troop_cooldown.server_offset = mainScene.player.fleet.server_offset
	negotiator_cooldown.server_offset = mainScene.player.fleet.server_offset
	colony_cooldown.server_offset = mainScene.player.fleet.server_offset
	
	for unitcd in mainScene.prt.unit_holder.get_children():
		match unitcd.type:
			0:
				troop_cooldown.unitUI = unitcd
			1:
				negotiator_cooldown.unitUI = unitcd
			2:
				scout_cooldown.unitUI = unitcd
			3:
				colony_cooldown.unitUI = unitcd
			4:
				ftl_cooldown.fleetUI = unitcd

func _update_cooldown():
	ftl_cooldown._init_cd()
	scout_cooldown._init_cd()
	troop_cooldown._init_cd()
	negotiator_cooldown._init_cd()
	colony_cooldown._init_cd()

func _on_back_button_down() -> void:
	mainScene._update_ship_status()
	mainScene.switch_to_fleet_status()

func display_tooltip(txt, hovering):
	if hovering :
		tooltip.visible = true
		tooltip.set_tooltip(txt)
	else :
		tooltip.visible = false

func _on_donation_button_down() -> void:
	pass # Replace with function body.

#region R&D GRID
## Built in code from the data the server sends, so the server's tables are the
## only place to change names, prices and effects.
const RESEARCH_COLUMNS = ["Scout", "Negotiator", "Troop", "Colony", "Ship"]
const RESEARCH_TIERS = 4
const CELL_SIZE = Vector2(220, 105)

@onready var research_tab = $"MarginContainer/TabContainer/R&D"
@onready var investment_tab = $"MarginContainer/TabContainer/Galactic Shop"
@onready var tab_container = $MarginContainer/TabContainer

var research_cells = {}   # "Column:tier" -> Button
var research_nodes = {}   # node id -> data from the server
var investment = {}       # project id -> data from the server
var investment_rows = {}  # project id -> {"bar", "status", "buttons"}
var research_message
var investment_message
var research_points_text = ""

static func format_cu(value) -> String:
	var digits = str(int(value))
	var out = ""
	while digits.length() > 3:
		out = " " + digits.right(3) + out
		digits = digits.left(digits.length() - 3)
	return digits + out

func _build_research_tab():
	for child in research_tab.get_children():
		child.visible = false # Old R&D level allocation, replaced by the grid
	research_message = Label.new()
	research_message.text = _research_intro()
	research_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	research_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	research_tab.add_child(research_message)

	var grid = GridContainer.new()
	grid.columns = RESEARCH_COLUMNS.size() + 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	research_tab.add_child(grid)

	grid.add_child(Control.new())
	for column in RESEARCH_COLUMNS:
		var header = Label.new()
		header.text = column
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(header)
	for tier in range(1, RESEARCH_TIERS + 1):
		var tier_label = Label.new()
		tier_label.text = "Tier " + str(tier)
		tier_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		grid.add_child(tier_label)
		for column in RESEARCH_COLUMNS:
			var cell = Button.new()
			cell.custom_minimum_size = CELL_SIZE
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.text = "?"
			cell.button_down.connect(_on_research_cell_pressed.bind(column, tier))
			cell.mouse_entered.connect(_on_research_cell_hovered.bind(column, tier, true))
			cell.mouse_exited.connect(_on_research_cell_hovered.bind(column, tier, false))
			grid.add_child(cell)
			research_cells[column + ":" + str(tier)] = cell

func _node_at(column, tier):
	for node_id in research_nodes:
		var node = research_nodes[node_id]
		if node["column"] == column and int(node["tier"]) == tier:
			return node_id
	return ""

func _project_for_ship_tier(tier):
	for project_id in investment:
		if int(investment[project_id]["ship_tier"]) == tier:
			return project_id
	return ""

func update_research(research):
	if research == null:
		return
	research_nodes = research["nodes"]
	research_points_text = "R&D points: %d available (%d earned from unit levels). Every %d points spent opens the next tier." % [research["points_available"], research["points_total"], research["tier_step"]]
	if research_message.modulate == Color.WHITE:
		research_message.text = _research_intro()
	for node_id in research_nodes:
		var node = research_nodes[node_id]
		var cell = research_cells.get(node["column"] + ":" + str(int(node["tier"])))
		if cell == null:
			continue
		cell.text = ("* " if node["active"] else "") + node["name"] + "\n%d/%d" % [node["rank"], node["ranks"]]
		if node["active"]:
			cell.text += "\nActive module"
		cell.disabled = node["refusal"] != ""
		if node["rank"] >= node["ranks"]:
			cell.modulate = Color(0.6, 1.0, 0.6)
		elif not node["open"]:
			cell.modulate = Color(1, 1, 1, 0.4)
		else:
			cell.modulate = Color.WHITE
	_update_ship_column()

func _update_ship_column():
	for tier in range(1, RESEARCH_TIERS + 1):
		var cell = research_cells["Ship:" + str(tier)]
		var project_id = _project_for_ship_tier(tier)
		if project_id == "":
			continue
		var project = investment[project_id]
		cell.text = project["name"] + "\n"
		if project["complete"]:
			cell.text += "1/1"
			cell.modulate = Color(0.6, 1.0, 0.6)
		else:
			cell.text += "0/1\nCommunity: %d%%" % int(100.0 * project["funded"] / project["cost"])
			cell.modulate = Color.WHITE if project["open"] else Color(1, 1, 1, 0.4)

func _on_research_cell_pressed(column, tier):
	if column == "Ship":
		tab_container.current_tab = tab_container.get_tab_idx_from_control(investment_tab)
		return
	var node_id = _node_at(column, tier)
	if node_id != "":
		mainScene.client.request_research(node_id)
		mainScene.wait_server_call()

func _on_research_cell_hovered(column, tier, hovering):
	if !hovering:
		display_tooltip("", false)
		return
	var text = ""
	if column == "Ship":
		var project_id = _project_for_ship_tier(tier)
		if project_id == "":
			return
		var project = investment[project_id]
		text = project["name"] + "\n" + project["desc"] + "\nFunded by all players: %s / %s CU" % [format_cu(project["funded"]), format_cu(project["cost"])]
	else:
		var node_id = _node_at(column, tier)
		if node_id == "":
			return
		var node = research_nodes[node_id]
		text = node["name"] + "\n" + node["desc"]
		if node["refusal"] != "":
			text += "\n(" + node["refusal"] + ")"
	display_tooltip(text, true)
#endregion

#region INVESTMENT CENTER
const INVEST_AMOUNTS = [1000, 10000, 100000]

func _build_investment_tab():
	for child in investment_tab.get_children():
		child.visible = false # Old Galactic Shop
	tab_container.set_tab_title(tab_container.get_tab_idx_from_control(investment_tab), "Investment Center")
	investment_message = Label.new()
	investment_message.text = "Community projects: every player's Core Units go into the same pot, and the bonus applies to everyone."
	investment_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	investment_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	investment_tab.add_child(investment_message)
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	investment_tab.add_child(scroll)
	var list = VBoxContainer.new()
	list.name = "Projects"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)

func update_investment(state):
	if state == null:
		return
	investment = state
	var list = investment_tab.get_node("ScrollContainer/Projects") if investment_tab.has_node("ScrollContainer/Projects") else null
	if list == null:
		for child in investment_tab.get_children():
			if child is ScrollContainer:
				list = child.get_child(0)
	# Ship upgrades first, in tier order, then the galaxy-wide projects
	var order = investment.keys()
	order.sort_custom(func(a, b):
		var ta = int(investment[a]["ship_tier"]); var tb = int(investment[b]["ship_tier"])
		if ta == 0: ta = 99
		if tb == 0: tb = 99
		return ta < tb if ta != tb else a < b)
	for project_id in order:
		if !investment_rows.has(project_id):
			investment_rows[project_id] = _make_project_row(list, project_id)
		var project = investment[project_id]
		var row = investment_rows[project_id]
		var prefix = "Ship tier %d - " % int(project["ship_tier"]) if int(project["ship_tier"]) > 0 else ""
		row["title"].text = prefix + project["name"]
		row["desc"].text = project["desc"]
		row["bar"].max_value = project["cost"]
		row["bar"].value = project["funded"]
		if project["complete"]:
			row["status"].text = "Complete"
		elif !project["open"]:
			row["status"].text = "Locked: fund the previous ship tier first"
		else:
			row["status"].text = "%s / %s CU" % [format_cu(project["funded"]), format_cu(project["cost"])]
		for button in row["buttons"]:
			button.disabled = project["complete"] or !project["open"]
	_update_ship_column()

func _make_project_row(list, project_id):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	list.add_child(row)
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var title = Label.new()
	var desc = Label.new()
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.modulate = Color(1, 1, 1, 0.75)
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 24)
	var status = Label.new()
	for control in [title, desc, bar, status]:
		info.add_child(control)
	var buttons = []
	for amount in INVEST_AMOUNTS:
		var button = Button.new()
		button.text = "+" + format_cu(amount)
		button.custom_minimum_size = Vector2(110, 50)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.button_down.connect(_on_invest_pressed.bind(project_id, amount))
		row.add_child(button)
		buttons.append(button)
	return {"title": title, "desc": desc, "bar": bar, "status": status, "buttons": buttons}

func _on_invest_pressed(project_id, amount):
	mainScene.client.request_invest(project_id, amount)
	mainScene.wait_server_call()

## Short feedback when the server refuses a purchase.
var message_serial = 0

func show_message(text):
	message_serial += 1
	var serial = message_serial
	for label in [research_message, investment_message, module_title]:
		if label != null:
			label.text = text
			label.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(4.0).timeout
	if serial != message_serial:
		return # A newer message is showing
	if research_message != null:
		research_message.modulate = Color.WHITE
		research_message.text = _research_intro()
	if module_title != null:
		module_title.modulate = Color.WHITE
		module_title.text = "Modules"
	if investment_message != null:
		investment_message.modulate = Color.WHITE
		investment_message.text = "Community projects: every player's Core Units go into the same pot, and the bonus applies to everyone."
#endregion

func _research_intro():
	var text = research_points_text if research_points_text != "" else "Units earn 1 R&D point per level."
	return text + "\n* = active module (equip it in Ship status). The Ship column is funded in the Investment Center."

#region MODULES (Ship status tab)
## Space is the number of modules you can equip; it grows with the highest R&D tier you opened.
@onready var ship_tab = $"MarginContainer/TabContainer/Ship status"
var module_list
var module_rows = {}
var module_title

func _build_module_list():
	get_node("MarginContainer/TabContainer/Ship status/Marge2/Status/Label/MarginContainer2/Space").text = "Space"
	module_title = Label.new()
	module_title.text = "Modules"
	module_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ship_tab.add_child(module_title)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ship_tab.add_child(scroll)
	module_list = VBoxContainer.new()
	module_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	module_list.add_theme_constant_override("separation", 6)
	scroll.add_child(module_list)

func update_modules(state):
	if state == null:
		return
	space.text = "%d / %d" % [state["used"], state["slots"]]
	for module_id in state["modules"]:
		var module = state["modules"][module_id]
		if !module_rows.has(module_id):
			var row = HBoxContainer.new()
			var label = Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var button = Button.new()
			button.custom_minimum_size = Vector2(150, 40)
			button.button_down.connect(_on_module_toggle.bind(module_id))
			row.add_child(label)
			row.add_child(button)
			module_list.add_child(row)
			module_rows[module_id] = {"label": label, "button": button, "equipped": false}
		var entry = module_rows[module_id]
		entry["equipped"] = module["equipped"]
		var cooldown = "%d min cooldown" % ceil(module["cooldown"] / 60.0)
		var cost = (", %s CU per use" % format_cu(module["cu_cost"])) if module["cu_cost"] > 0 else ""
		entry["label"].text = "%s - %s (%s%s)" % [module["name"], module["desc"], cooldown, cost]
		if !module["unlocked"]:
			entry["label"].text += "\n   Locked: " + module["source"]
			entry["label"].modulate = Color(1, 1, 1, 0.45)
		else:
			entry["label"].modulate = Color.WHITE
		entry["button"].text = "Remove" if module["equipped"] else "Equip"
		entry["button"].disabled = !module["unlocked"]

func _on_module_toggle(module_id):
	mainScene.client.request_equip_module(module_id, !module_rows[module_id]["equipped"])
	mainScene.wait_server_call()
#endregion

