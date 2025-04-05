extends Node

# Lists to store multiple people in a coffin
class Person:
	var first_name: String
	var last_name: String
	var birth_date: String
	var death_date: String
	
	func _init(f_name: String, l_name: String, b_date: String, d_date: String):
		first_name = f_name
		last_name = l_name
		birth_date = b_date
		death_date = d_date
	
	func get_full_name() -> String:
		return first_name + " " + last_name
	
	func get_date_range() -> String:
		if birth_date.is_empty() or death_date.is_empty():
			return ""
		return birth_date + " - " + death_date
	
	func get_display_line() -> String:
		return get_full_name() + " (" + get_date_range() + ")"

# Collection of people in the coffin
var people: Array[Person] = []

# Name collections loaded from files
var first_names: Array = []
var last_names: Array = []

@export var n_families: int = 3

# Legacy access to first person (for backward compatibility)
@export var first_name: String = "":
	set(value):
		first_name = value
		_update_first_person()
		
@export var last_name: String = "":
	set(value):
		last_name = value
		_update_first_person()
		
@export var birth_date: String = "":
	set(value):
		birth_date = value
		_update_first_person()
		
@export var death_date: String = "":
	set(value):
		death_date = value
		_update_first_person()
		
@export var epitaph: String = ""

# Signals
signal data_updated

func _ready():
	# Load names from files
	load_names_from_files()
	
	# Initialize with random data if empty
	if people.is_empty():
		randomize_data()

# Load first and last names from text files
func load_names_from_files() -> void:
	# Load first names
	var first_names_file = FileAccess.open("res://assets/names/first_names.txt", FileAccess.READ)
	if first_names_file:
		while not first_names_file.eof_reached():
			var line = first_names_file.get_line().strip_edges()
			if not line.is_empty():
				first_names.append(line)
	
	# Load last names
	var last_names_file = FileAccess.open("res://assets/names/last_names.txt", FileAccess.READ)
	if last_names_file:
		while not last_names_file.eof_reached():
			var line = last_names_file.get_line().strip_edges()
			if not line.is_empty():
				last_names.append(line)
	
	# Fallback in case files couldn't be loaded
	if first_names.is_empty():
		first_names = ["John", "Mary", "Robert", "Elizabeth", "William"]
	
	if last_names.is_empty():
		last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones"]

# Set the first person in the coffin (for backward compatibility)
func _update_first_person():
	if people.is_empty():
		if first_name != "" or last_name != "":
			var person = Person.new(first_name, last_name, birth_date, death_date)
			people.append(person)
	else:
		# Update the first person with current values
		people[0].first_name = first_name
		people[0].last_name = last_name
		people[0].birth_date = birth_date
		people[0].death_date = death_date
	
	emit_signal("data_updated")

# Add a person to the coffin
func add_person(first_name: String, last_name: String, birth_date: String, death_date: String) -> void:
	var person = Person.new(first_name, last_name, birth_date, death_date)
	people.append(person)
	
	# Keep the exported variables in sync with the first person
	if people.size() == 1:
		self.first_name = first_name
		self.last_name = last_name
		self.birth_date = birth_date
		self.death_date = death_date
	
	emit_signal("data_updated")

# Get the full name (for tooltip title - first person or combined)
func get_full_name() -> String:
	if people.is_empty():
		return ""
		
	if people.size() == 1:
		return people[0].get_full_name()
	else:
		# For multiple people, use the family name with number
		return people[0].last_name + " Family (" + str(people.size()) + ")"


# Get the detailed display text with all people
func get_detailed_text() -> String:
	if people.is_empty():
		return ""
	
	var text = ""
	for i in range(people.size()):
		text += people[i].get_display_line()
		if i < people.size() - 1:
			text += "\n"
	
	return text

# Generate random data for testing
func randomize_data() -> void:
	# Clear existing data
	people.clear()
	
	# Make sure names are loaded
	if first_names.is_empty() or last_names.is_empty():
		load_names_from_files()
	
	# Pick random name
	var first_name = first_names[randi() % first_names.size()]
	var last_name = last_names.slice(0, n_families)[randi() % n_families]
	
	# Generate random dates
	var birth_year = str(randi_range(1900, 1980))
	var death_year = str(randi_range(int(birth_year) + 20, 2025))
	
	# Create person
	add_person(first_name, last_name, birth_year, death_year)
	
	emit_signal("data_updated") 
