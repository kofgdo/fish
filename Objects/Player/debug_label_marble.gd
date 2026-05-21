extends Label
#MARB
@onready var marble: Marble = $"../../Marble"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _draw():
	if marble.brokensphere>0:
		draw_rect(Rect2(100, 100, 200, 150), Color.RED, true)
	if marble.bump_sphere>0:
		draw_rect(Rect2(400, 100, 200, 150), Color.YELLOW, true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#queue_redraw()
	
	var av : Vector3 = marble.angular_velocity
	var lv : Vector3 = marble.linear_velocity
	var avx : float = av.x
	var avy : float = av.y
	var avz : float = av.z
	var lvx : float = lv.x
	var lvy : float = lv.y
	var lvz : float = lv.z
	
	
	text = "av X: "+ str(snapped(avx,0.1)) \
	+" Y: "+ str(snapped(avy,0.1)) \
	+" Z: "+ str(snapped(avz,0.1)) \
	+" SUM: "+ str(snapped(av.length(),0.1)) \
	+"\nlv X: "+ str(snapped(lvx,0.1)) \
	+" Y: "+ str(snapped(lvy,0.1)) \
	+" Z: "+ str(snapped(lvz,0.1)) \
	+" SUM: "+ str(snapped(lv.length(),0.1)) \
	+"\n spd manual?"+ str(marble.ismarbletopmanualspeeding) \
	+" torque?"+ str(marble.ismarbletoptorquing) \
	+" downhill?"+ str(marble.ismarbletopdownhillspeeding) \
	+"\n grounded full?" +str(marble.grounded) \
	+" contact?" +str(marble.contactgrounded) \
	+" shapecast?" +str(marble.raycheckgrounded) \
	+"\n contactgrounded? " +str(marble.contactgrounded) \
	+"\n shattercount: "+str(marble.shattercount) \
	+"\n skidmode: "+str(marble.skidmode) 
	
	pass

#func _draw():
	#var mavint : int = clamp(round(marble.angular_velocity*10),0,255)
	#var mlvint : int = clamp(round(marble.linear_velocity*10),0,255)
	
	#var as_color = Color.from_rgba8(255,255-mavint,255-mavint)
	#var ls_color = Color.from_rgba8(255,255-mlvint,255-mlvint)
	
	#var as_rect = Rect2(Vector2(100, 100), Vector2(200, 150))
	#draw_rect(as_rect,as_color,true)
