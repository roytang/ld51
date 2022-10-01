extends Node2D

var stages = [
	# "res://Stages/Stage004.tscn",
	"res://Stages/Stage000.tscn",
	"res://Stages/Stage001.tscn",
	"res://Stages/Stage002.tscn",
	"res://Stages/Stage003.tscn",
	"res://Stages/Stage004.tscn",
	]

var reload_count = 0
var current_stage = -1
var current_stage_ref 
var waiting_for_reload_input = false


# Called when the node enters the scene tree for the first time.
func _ready():
	next_stage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Stage_stage_success():
	print("stage success!")
	$HUD/SuccessMessageBox.visible = true

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
		
	if current_stage_ref.name == "Stage000":
		$HUD/TimerDisplay.visible = false
	else:
		$HUD/TimerDisplay.visible = true
		
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
		reload_count += 1
		next_stage()
		$HUD/FailureMessageBox.visible = false
		$HUD/SuccessMessageBox.visible = false
	if event.is_action_pressed("reload") and is_instance_valid(current_stage_ref):
		reload_count += 1
		load_stage()
		$HUD/FailureMessageBox.visible = false
		$HUD/SuccessMessageBox.visible = false

