# To be used as autoload, class name intentionally omitted.
extends Node

class ScoreEntry:
	var score_value : int = 0
	var name : String = ""

const _HIGHSCORES_PATH : String = "user://highscores.cfg"
const _MAX_NUM_ENTRIES : int = 3

var highscores : Array[ScoreEntry] = []


func add_score_entry(entry: ScoreEntry) -> void:
	# Prune name to three characters:
	entry.name = entry.name.substr(0, 3)
	# Make name all upper case:
	entry.name = entry.name.to_upper()

	highscores.append(entry)
	highscores.sort_custom(func(a, b): return a.score_value > b.score_value)
	if highscores.size() > _MAX_NUM_ENTRIES:
		highscores = highscores.slice(0, _MAX_NUM_ENTRIES)


func reset_highscores() -> void:
	highscores.clear()

	var entry1 = ScoreEntry.new()
	entry1.score_value = 100000
	entry1.name = "ZPX"
	highscores.append(entry1)

	var entry2 = ScoreEntry.new()
	entry2.score_value = 50000
	entry2.name = "AST"
	highscores.append(entry2)

	var entry3 = ScoreEntry.new()
	entry3.score_value = 12500
	entry3.name = "TYL"
	highscores.append(entry3)


func is_top_three_score(score : int) -> bool:
	if highscores.size() < 3:
		return true

	return score > highscores[2].score_value


func read_highscores_file() -> void:
	var highscores_file = ConfigFile.new()
	var error : Error = highscores_file.load(_HIGHSCORES_PATH)
	if error != OK:
		push_warning("Not loading highscores file, doesn't exist. Creating. This is expected on first run.")
		highscores_file.save(_HIGHSCORES_PATH)
		reset_highscores()
		return

	# Gather all entries by index until missing
	for i in _MAX_NUM_ENTRIES:
		var key_score_value = "entry_%d_score_value" % i
		var key_name = "entry_%d_name" % i
		if not highscores_file.has_section_key("highscores", key_score_value):
			push_warning("Highscores file is malformed: entry %d missing score value. Not loading." % i)
			reset_highscores()
			return
		if not highscores_file.has_section_key("highscores", key_name):
			push_warning("Highscores file is malformed: entry %d missing name. Not loading." % i)
			reset_highscores()
			return

		var entry = ScoreEntry.new()
		entry.score_value = highscores_file.get_value("highscores", key_score_value)
		entry.name = highscores_file.get_value("highscores", key_name)
		add_score_entry(entry)
	
	assert(highscores.size() == _MAX_NUM_ENTRIES)


func save_highscores_file() -> void:
	var highscores_file = ConfigFile.new()
	var error : Error = highscores_file.load(_HIGHSCORES_PATH)
	if error != OK:
		push_error("Cannot save highscores, file expected but doesn't exist. Creating new file.")

	# Clear previous entries in the section
	if highscores_file.has_section("highscores"):
		highscores_file.erase_section("highscores")

	# Write each score entry: overall_score and all phase_scores
	assert(highscores.size() == _MAX_NUM_ENTRIES)
	for i in highscores.size():
		var entry = highscores[i]
		highscores_file.set_value("highscores", "entry_%d_score_value" % i, entry.score_value)
		highscores_file.set_value("highscores", "entry_%d_name" % i, entry.name)

	highscores_file.save(_HIGHSCORES_PATH)
	print("Successfully saved highscores to file.")
