class_name JsonLoader extends RefCounted
##
## JsonLoader — load JSON file or directory into Dictionary.
## GDD §B (data schema), IMPLEMENTATION_PLAN T2.1
##

static func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: " + path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var result = JSON.parse_string(text)
	if result == null or not result is Dictionary:
		push_error("JSON parse failed: " + path)
		return {}
	return result

static func load_dir(dir_path: String) -> Dictionary:
	## Load all *.json files in a directory, key by their "id" field.
	var out: Dictionary = {}
	if not DirAccess.dir_exists_absolute(dir_path):
		# Try with res:// prefix
		if not dir_path.begins_with("res://"):
			dir_path = "res://" + dir_path
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("Dir not found: " + dir_path)
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".json"):
			var data := load_file(dir_path.path_join(f))
			if data.has("id"):
				out[data["id"]] = data
			else:
				push_warning("JSON missing 'id' field: " + f)
		f = dir.get_next()
	dir.list_dir_end()
	return out
