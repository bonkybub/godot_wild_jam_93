extends Label

@onready var ScoreCounter: Label = $"."

var CurrentScore: int 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentScore = GameManager.player_money
	ScoreCounter.text = str(CurrentScore)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# This is so ugly, but I dont feel like setting up an event or something when score is updated
	if CurrentScore != GameManager.player_money:
		CurrentScore = GameManager.player_money
		ScoreCounter.text = str(CurrentScore)
	
	pass
