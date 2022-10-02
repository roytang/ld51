extends Area2D

signal bonus
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BonusStar_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("bonus")
		queue_free()
