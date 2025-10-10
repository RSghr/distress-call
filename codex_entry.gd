extends HBoxContainer

@onready var label = $MarginContainer/Label
@onready var content = $MarginContainer2/Content

@export var codex_idx = ""
@export var text_size = 14

var mainScene

func _ready() -> void:
	mainScene = get_tree().root.get_child(0)
	content.add_theme_font_size_override("normal_font_size",text_size)
	match codex_idx :
		#Player Tab
		"Player":
			label.text = codex_idx
			content.text = "You are in command of a fleet and you are tasked to conquer the galaxy along with your teammates. (other players connected) \nThis codex will teach you about everything you need to know.\n\n If something is missing, just send a message to Pengus!"
		"Fleet":
			label.text = codex_idx
			content.text = "It is you own HQ and base of operation. It will display everything you need to know about your ship's status, as well as your units.\n- [u]SHIP STATUS :[/u] you can rename your ship, see how much upgrades have been allocated, and when is the next FTL jump available.\n- [u]UNIT STATUS :[/u] where you can rename your units, see on which planet they are, and what is their current level.\n- [u]R&D :[/u] where you can upgrade your units, allocating levels how ever you want, as long as the unit is NOT deployed."

		"Units":
			label.text = codex_idx
			content.text = "They are your main force. They carry out missions wherever you send them (with 106% success rate!)\nEach one of them has its unique purpose, but they all share these same characteristics :\n- [u]Upgrade level :[/u] which determines the strength of the unit when sent to deal with a mission.\n- [u]Price :[/u] Each unit has a base price which increases depending on its upgrade level.\n- [u]Cooldown :[/u] Each unit has a specific cooldown."

		"Economy":
			label.text = codex_idx
			content.text = "You have guessed it, in order to scout, conquer and colonize a planet, you need to have money. In this world, Core Units is the main currency, tradable with every civilisation encountered.\n Every X minutes, all players recieve a portion of each planet's wealth under the players' control, plus a bonus for how many planets have been conquered."
		#Unit Tab
		"Scout Role":
			label.text = codex_idx
			content.text = "Scouts allow you to gether extensive information about the planet, and gives valuable intel for the rest of your units. They are the spear guiding your conquest!\n\nUpgrading them allows them to give a better estimate to how much Core Units can be harvested in a planet."

		"Scout Stats":
			label.text = codex_idx
			content.text = "- [u]Base Price :[/u] 25000\n- [u]Base Cooldown :[/u] 25 seconds"

		"Troop Role":
			label.text = codex_idx
			content.text = "Troops are your special forces when a civilisation is being unruly and needs to be shutdown.\nFrom the assassination of their resillient leaders, to mass extermination of dissidents, these units will reduce the will of these rebels, but at the cost of the desctruction and consumption of the planet's own wealth reserve.\n\nUpgrading them allows them to be more destructive in every way."

		"Troop Stats":
			label.text = codex_idx
			content.text = "- [u]Base Price :[/u] 10000\n- [u]Base Cooldown :[/u] 20 seconds"

		"Negotiator Role":
			label.text = codex_idx
			content.text = "Negotiators are the only units who have 2 uses.\nBefore conquering a planet, they align the planets populace with our intentions, with out hurting the reserves of core units harverstable.\nOnce the planet is conquered, they can be sent again in order to open up new processing facilities, and put more workers in the mines, increasing the planet's current wealth.\n\nUpgrading them allows them to reduce more will, and help planets to yield more."

		"Negotiator Stats":
			label.text = codex_idx
			content.text = "- [u]Base Price :[/u] 5000\n- [u]Base Cooldown :[/u] 15 seconds"

		"Colony Role":
			label.text = codex_idx
			content.text = "This is the only unit that requires you to be on the planet to be sent.\nGiven the initial payload, they can't fast travel towards a planet. They will fully conquer the planet and integrate them in the IPP (intergalactic payout program).\n\nUpgrading them allows them to boost the wealth of the planet by a substantial amount."

		"Colony Stats":
			label.text = codex_idx
			content.text = "- [u]Base Price :[/u] 50000\n- [u]Base Cooldown :[/u] 30 seconds"
		#Galaxy Tab
		"Major Order":
			label.text = codex_idx
			content.text = "You have to conquer all 500 planets!"

		"Planets":
			label.text = codex_idx
			content.text = "Planets are characterised by multiple things :"
			content.text += "\n- [u]Race & Culture[/u] : It affects how they respond to your actions. (in this demo, it does not affect gameplay)"
			content.text += "\n- [u]Wealth[/u] : The amount of core units that can be harvested."
			content.text += "\n- [u]Will[/u] : How willing a civilisation is towards you controlling their planet."

		"":
			label.text = codex_idx
			content.text = ""
