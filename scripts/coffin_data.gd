extends Node

# Personal data for the coffin
@export var first_name: String = ""
@export var last_name: String = ""
@export var birth_date: String = ""
@export var death_date: String = ""
@export var epitaph: String = ""

# Signals
signal data_updated

func _ready():
    # Initialize with random data if none provided
    if first_name.is_empty() and last_name.is_empty():
        randomize_data()

# Set the person's first name
func set_first_name(first_name: String) -> void:
    self.first_name = first_name
    emit_signal("data_updated")

# Set the person's last name
func set_last_name(last_name: String) -> void:
    self.last_name = last_name   
    emit_signal("data_updated")

# Set the birth date
func set_birth_date(date: String) -> void:
    birth_date = date
    emit_signal("data_updated")

# Set the death date
func set_death_date(date: String) -> void:
    death_date = date
    emit_signal("data_updated")

# Set the epitaph (memorial text)
func set_epitaph(text: String) -> void:
    epitaph = text
    emit_signal("data_updated")

# Get the full name
func get_full_name() -> String:
    return first_name + " " + last_name
    
# Get the date range
func get_date_range() -> String:
    if birth_date.is_empty() or death_date.is_empty():
        return ""
    return birth_date + " - " + death_date

# Generate random data for testing
func randomize_data() -> void:
    var first_names = ["John", "Mary", "Robert", "Elizabeth", "William", "Sarah", "James", "Patricia", "Michael", "Jennifer"]
    var last_names = ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor"]
    
    # Pick random names
    first_name = first_names[randi() % first_names.size()]
    last_name = last_names[randi() % last_names.size()]
    
    # Generate random dates from the past
    var birth_year = str(randi_range(1900, 1980))
    var death_year = str(randi_range(int(birth_year) + 20, 2023))
    
    birth_date = birth_year
    death_date = death_year
    
    # Generate a random epitaph
    var epitaphs = [
        "Beloved parent and friend",
        "Forever in our hearts",
        "Rest in peace",
        "Until we meet again",
        "A life well lived"
    ]
    
    epitaph = epitaphs[randi() % epitaphs.size()]
    emit_signal("data_updated") 