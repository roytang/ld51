extends Node2D

signal time_update
signal stage_success
signal stage_failed

export var failable = true

var time_start:float = 0.0
var time_now:float = 0.0
var _player
var success = false
var target_time = 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	_player = $Player
	if is_instance_valid(_player):
		_player.connect("hit", self, "_on_Player_hit")
	var sb = $StageBounds
	if is_instance_valid(sb):
		sb.connect("body_exited", self, "_on_StageBounds_body_exited")
	
# called by instantiator
func start_timer():
	time_start = Time.get_unix_time_from_system()
	$Timer.wait_time = target_time
	$Timer.start()
	# set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now = Time.get_unix_time_from_system()
	# compute remaining time
	var unix_time: float = target_time - (time_now - time_start)
	var unix_time_int: int = unix_time
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	var ms: int = (unix_time - unix_time_int) * 1000.0
	var mystr := "%02d:%03d" % [dt.second, ms]
	# print(mystr)
	if unix_time > 0.0:
		emit_signal("time_update", "%02d" % [dt.second], "%03d" % [ms])
		emit_signal("time_update", "%02d" % [dt.second], "%03d" % [ms])
	else:
		emit_signal("time_update", "00", "000")

func _on_Timer_timeout():
	print("TIMEOUT")
	if failable:
		emit_signal("time_update", "00", "000")
		set_process(false)
		emit_signal("stage_failed", "You took too long!")


func _on_Customer_delivered():
	set_process(false)
	$Timer.stop()
	emit_signal("stage_success")


func _on_Player_hit():
	set_process(false)
	emit_signal("stage_failed", "You dropped the pizza!")

func _on_StageBounds_body_exited(body):
	print(body)
	if body.is_in_group("player"):
		set_process(false)
		_player.dead = true
		emit_signal("stage_failed", "You fell in a hole!")
