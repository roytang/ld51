extends Node2D

signal time_update
signal stage_success

var time_start:float = 0.0
var time_now:float = 0.0



# Called when the node enters the scene tree for the first time.
func _ready():
	time_start = Time.get_unix_time_from_system()
	$Timer.start()
	# set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now = Time.get_unix_time_from_system()
	# compute remaining time
	var unix_time: float = 10.0 - (time_now - time_start)
	var unix_time_int: int = unix_time
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	var ms: int = (unix_time - unix_time_int) * 1000.0
	var mystr := "%02d:%03d" % [dt.second, ms]
	# print(mystr)
	if unix_time > 0.0:
		emit_signal("time_update", "%02d" % [dt.second], "%03d" % [ms])
	else:
		emit_signal("time_update", "00", "000")

func _on_Timer_timeout():
	print("TIMEOUT")


func _on_Customer_delivered():
	set_process(false)
	emit_signal("stage_success")
