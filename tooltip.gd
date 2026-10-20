extends Panel

@onready var tooltiptxt = $RichTextLabel

const MIN_HEIGHT = 150.0
const PADDING = 15.0

## The panel grows to fit longer descriptions instead of cutting them off.
func set_tooltip(txt):
	tooltiptxt.text = txt
	tooltiptxt.fit_content = true
	await get_tree().process_frame
	var text_height = max(tooltiptxt.get_content_height(), MIN_HEIGHT - PADDING * 2)
	tooltiptxt.size.y = text_height
	size.y = text_height + PADDING * 2
