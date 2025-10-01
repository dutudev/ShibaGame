extends RichTextLabel

var time = 1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if text == "Anchor point key available in shop":
		time -= delta
		if time <= 0:
			time = 0.5
			visible = !visible
	else:
		visible = true
		time = 1.0
