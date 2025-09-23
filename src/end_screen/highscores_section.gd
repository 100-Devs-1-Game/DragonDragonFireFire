class_name HighscoresSection
extends Control

@onready var _highscore1_label : Label = $Highscore1
@onready var _highscore2_label : Label = $Highscore2
@onready var _highscore3_label : Label = $Highscore3

@onready var _name1_label : Label = $Name1
@onready var _name2_label : Label = $Name2
@onready var _name3_label : Label = $Name3


func _process(_delta : float) -> void:
	_update_labels()


func _update_labels():
	if Highscores.highscores.size() > 0:
		_highscore1_label.text = str(Highscores.highscores[0].score_value)
		_name1_label.text = Highscores.highscores[0].name
	else:
		_highscore1_label.text = "-----"
		_name1_label.text = "---"

	if Highscores.highscores.size() > 1:
		_highscore2_label.text = str(Highscores.highscores[1].score_value)
		_name2_label.text = Highscores.highscores[1].name
	else:
		_highscore2_label.text = "-----"
		_name2_label.text = "---"

	if Highscores.highscores.size() > 2:
		_highscore3_label.text = str(Highscores.highscores[2].score_value)
		_name3_label.text = Highscores.highscores[2].name
	else:
		_highscore3_label.text = "-----"
		_name3_label.text = "---"
