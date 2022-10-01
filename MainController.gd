extends Node2D

var stages = [
	"res://Stages/Stage000.tscn",
	"res://Stages/Stage001.tscn",
	"res://Stages/Stage002.tscn",
	"res://Stages/Stage003.tscn",
	"res://Stages/Stage004.tscn",
	"res://Stages/Stage005.tscn",
	"res://Stages/Ending.tscn",
	]

var reload_count = 0
var current_stage = -1
var current_stage_ref 
var waiting_for_reload_input = false
var bonus_time:float = 0.0
var bonus_time_str


# Called when the node enters the scene tree for the first time.
func _ready():
	next_stage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Stage_stage_success():
	print("stage success!")
	$HUD/SuccessMessageBox.visible = true
	var seconds = $HUD/TimerDisplay/SecondsLabel.text
	var ms = $HUD/TimerDisplay/MillisecondsLabel.text

	$HUD/SuccessMessageBox/ColorRect/Label2.text = "Bonus time: " + seconds + ":" + ms
	bonus_time = int(seconds) * 1000 + int(ms)
	bonus_time = bonus_time / 1000
	print(bonus_time)

func _on_Stage_stage_failed(message):
	print("stage failed!")
	$HUD/FailureMessageBox.visible = true
	$HUD/FailureMessageBox/ColorRect/Label.text = message

func load_stage():
	var stage_path = stages[current_stage]
	var scene = load(stage_path).instance()
	if is_instance_valid(current_stage_ref):
		remove_child(current_stage_ref)
	current_stage_ref = scene
	add_child(scene)
	call_deferred("_attach_events")
	
	print(current_stage_ref.name)
	current_stage_ref.target_time = current_stage_ref.target_time + bonus_time
	current_stage_ref.start_timer()
		
	$HUD/TimerDisplay.visible = current_stage_ref.failable
	
	if current_stage_ref.name == "Ending":
		# show stats
		$HUD/SuccessMessageBox/ColorRect/Label.text = "You finished all your deliveries! WELL DONE!"
		$HUD/SuccessMessageBox/ColorRect/Label2.text = $HUD/SuccessMessageBox/ColorRect/Label2.text + "\nReloads: " + str(reload_count)
		$HUD/SuccessMessageBox/ColorRect/Label3.text = "[N]: Start a new game"
		$HUD/SuccessMessageBox.visible = true
	else:
		$HUD/SuccessMessageBox/ColorRect/Label.text = "DELIVERY COMPLETE!"
		$HUD/SuccessMessageBox/ColorRect/Label3.text = "[N]: Continue to the next stage!"
		$HUD/SuccessMessageBox.visible = false
		
func next_stage():
	current_stage = current_stage + 1
	load_stage()

func _attach_events():
	if is_instance_valid(current_stage_ref):
		current_stage_ref.connect("stage_failed", self, "_on_Stage_stage_failed")
		current_stage_ref.connect("stage_success", self, "_on_Stage_stage_success")
		current_stage_ref.connect("time_update", $HUD, "_on_Stage_time_update")
	
func _input(event):
	if event.is_action_pressed("next") and is_instance_valid(current_stage_ref):
		if not $HUD/SuccessMessageBox.visible and current_stage_ref.failable:
			return
		$HUD/SuccessMessageBox.visible = false
		next_stage()
		$HUD/FailureMessageBox.visible = false
	if event.is_action_pressed("reload") and is_instance_valid(current_stage_ref):
		reload_count += 1
		$HUD/SuccessMessageBox.visible = false
		load_stage()
		$HUD/FailureMessageBox.visible = false

