extends Label
#MARB
@onready var fish: Fish = $"../../Feesh"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#queue_redraw()
	
	var av : Vector3 = fish.angular_velocity
	var lv : Vector3 = fish.linear_velocity
	var avx : float = av.x
	var avy : float = av.y
	var avz : float = av.z
	var lvx : float = lv.x
	var lvy : float = lv.y
	var lvz : float = lv.z
	#var plus : bool = false
	#var minus : bool = false
	
	text = "av X: "+ str(snapped(avx,0.1)) \
	+" Y: "+ str(snapped(avy,0.1)) \
	+" Z: "+ str(snapped(avz,0.1)) \
	+"\nlv X: "+ str(snapped(lvx,0.1)) \
	+" Y: "+ str(snapped(lvy,0.1)) \
	+" Z: "+ str(snapped(lvz,0.1)) \
	+" PLUS: "+ str(fish.plus) \
	+" MINUS: "+ str(fish.minus) \
	+"supertorpedo_speed: "+str(fish.supertorpedo_speed)
	pass

#func _draw():
	#var mavint : int = clamp(round(marble.angular_velocity*10),0,255)
	#var mlvint : int = clamp(round(marble.linear_velocity*10),0,255)
	
	#var as_color = Color.from_rgba8(255,255-mavint,255-mavint)
	#var ls_color = Color.from_rgba8(255,255-mlvint,255-mlvint)
	
	#var as_rect = Rect2(Vector2(100, 100), Vector2(200, 150))
	#draw_rect(as_rect,as_color,true)
