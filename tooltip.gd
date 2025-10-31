extends Panel

@onready var tooltiptxt = $RichTextLabel

func set_tooltip(txt):
	tooltiptxt.text = txt
