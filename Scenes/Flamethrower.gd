extends AudioStreamPlayer

var enemies_firing = 0
@onready var flamethrower = $"."
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.add_flamer.connect(add_flamer)
	GlobalSignals.destroy_flamer.connect(destroy_flamer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enemies_firing == 0:
		flamethrower.playing = false
	if (enemies_firing > 0) and (flamethrower.playing == false):
		flamethrower.playing = true
	print(enemies_firing)
	
func add_flamer():
	enemies_firing+=1
	print("increasing")
	
func destroy_flamer():
	enemies_firing-=1
	print("decreasing")
