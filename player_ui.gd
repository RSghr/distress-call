extends Control

@onready var ship_name = $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer/Ship_name"
@onready var space = $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer2/Space"
@onready var ftl_cooldown = $"MarginContainer/TabContainer/Ship status/Marge2/Status/Values/MarginContainer3/Cooldown_FTL"

@onready var scout_values = $"MarginContainer/TabContainer/Unit status/Values/ScoutContainer/VBoxContainer"
@onready var troop_values = $"MarginContainer/TabContainer/Unit status/Values/TroopContainer/VBoxContainer"
@onready var negotiator_values = $"MarginContainer/TabContainer/Unit status/Values/NegotiatorContainer/VBoxContainer"
@onready var colony_values = $"MarginContainer/TabContainer/Unit status/Values/ColonyContainer/VBoxContainer"

@onready var scout_upgrade = $"MarginContainer/TabContainer/R&D/ScoutUpgrade"
@onready var troop_upgrade = $"MarginContainer/TabContainer/R&D/TroopUpgrade2"
@onready var negotiator_upgrade = $"MarginContainer/TabContainer/R&D/NegotiatorUpgrade3"
@onready var colony_upgrade = $"MarginContainer/TabContainer/R&D/ColonyUpgrade4"

@onready var scout_cooldown = $"MarginContainer/TabContainer/Unit Cooldown/Cooldown/ScoutContainer/cooldown_unit"
@onready var troop_cooldown = $"MarginContainer/TabContainer/Unit Cooldown/Cooldown/TroopContainer/cooldown_unit"
@onready var negotiator_cooldown = $"MarginContainer/TabContainer/Unit Cooldown/Cooldown/NegotiatorContainer/cooldown_unit"
@onready var colony_cooldown = $"MarginContainer/TabContainer/Unit Cooldown/Cooldown/ColonyContainer/cooldown_unit"

@onready var playerGlobalResources = $PlayerGlobalResources

var mainScene

#On ready attach objects
func _ready():
	mainScene = get_tree().root.get_child(0)

#SHIP STATUS TAB
func _on_ship_name_text_submitted(new_text: String) -> void:
	ship_name.text = new_text
	mainScene.player.fleet.fleet_params["fleet_name"] = new_text
	mainScene._update_ship_status()

#UNIT STATUS TAB
func _on_troop_unit_text_submitted(new_text: String) -> void:
	troop_values.get_node("MarginContainer/Troop_Unit").text = new_text
	mainScene.player.fleet.troop.unit_params["unit_name"] = new_text
	mainScene._update_ship_status()

func _on_negotiator_unit_text_submitted(new_text: String) -> void:
	negotiator_values.get_node("MarginContainer/Negotiator_Unit").text = new_text
	mainScene.player.fleet.negotiator.unit_params["unit_name"] = new_text
	mainScene._update_ship_status()

func _on_colony_unit_text_submitted(new_text: String) -> void:
	colony_values.get_node("MarginContainer/Colony_Unit").text = new_text
	mainScene.player.fleet.colony.unit_params["unit_name"] = new_text
	mainScene._update_ship_status()

func _on_scout_unit_text_submitted(new_text: String) -> void:
	scout_values.get_node("MarginContainer/Scout_Unit").text = new_text
	mainScene.player.fleet.scout.unit_params["unit_name"] = new_text
	mainScene._update_ship_status()

func _update_unit_values(unit_value):
	match unit_value["unit_type"] :
		0 :	#Troop
			troop_values.get_node("MarginContainer/Troop_Unit").text = unit_value["unit_name"]
			troop_values.get_node("MarginContainer2/Troop_Upgrade").text = "Lvl." + str(int(unit_value["upgrade"] * 10))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				troop_values.get_node("MarginContainer3/Troop_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				troop_values.get_node("MarginContainer3/Troop_position").text = unit_value["unit_position"]
		1 :	#Negotiator
			negotiator_values.get_node("MarginContainer/Negotiator_Unit").text = unit_value["unit_name"]
			negotiator_values.get_node("MarginContainer2/Negotiator_Upgrade").text = "Lvl." + str(int(unit_value["upgrade"] * 10))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				negotiator_values.get_node("MarginContainer3/Negotiator_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				negotiator_values.get_node("MarginContainer3/Negotiator_position").text = unit_value["unit_position"]
		2 :	#Scout
			scout_values.get_node("MarginContainer/Scout_Unit").text = unit_value["unit_name"]
			scout_values.get_node("MarginContainer2/Scout_Upgrade").text = "Lvl." + str(int(unit_value["upgrade"] * 10))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				scout_values.get_node("MarginContainer3/Scout_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				scout_values.get_node("MarginContainer3/Scout_position").text = unit_value["unit_position"]
		3 :	#Colony
			colony_values.get_node("MarginContainer/Colony_Unit").text = unit_value["unit_name"]
			colony_values.get_node("MarginContainer2/Colony_Upgrade").text = "Lvl." + str(int(unit_value["upgrade"] * 10))
			if unit_value["unit_position"] == "Fleet" and mainScene.player.fleet.fleet_params["fleet_name"] != "":
				colony_values.get_node("MarginContainer3/Colony_position").text = mainScene.player.fleet.fleet_params["fleet_name"]
			else :
				colony_values.get_node("MarginContainer3/Colony_position").text = unit_value["unit_position"]

#R&D TAB
func _update_upgrade_values(unit_value):
	match unit_value["unit_type"] :
		0 : #Troop
			troop_upgrade._init_stat()
		1 : #Negotiator
			negotiator_upgrade._init_stat()
		2 : # Scout
			scout_upgrade._init_stat()
		3 : #Colony
			colony_upgrade._init_stat()

func _init_upgrade():
	scout_upgrade.unit = mainScene.player.fleet.scout
	troop_upgrade.unit = mainScene.player.fleet.troop
	negotiator_upgrade.unit = mainScene.player.fleet.negotiator
	colony_upgrade.unit = mainScene.player.fleet.colony
	
func _update_PGR():
	playerGlobalResources.CoreUnit.text = str(mainScene.player.fleet.fleet_params["CoreUnit"])
	mainScene.player.calcul_curr_upgrades(5)
	space.text = str(mainScene.player.fleet.fleet_params["current_space"]) + " / " + str(mainScene.player.fleet.fleet_params["total_space"])

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

func _update_cooldown():
	ftl_cooldown._init_cd()
	scout_cooldown._init_cd()
	troop_cooldown._init_cd()
	negotiator_cooldown._init_cd()
	colony_cooldown._init_cd()
