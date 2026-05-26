extends Node2D

#region Preload Assets
@onready var player : RigidBody2D = $Player
@onready var spawn : Node2D = $Spawn
@onready var ray : Node2D = $Rays

# tentacle tips
@onready var tip1 : StaticBody2D = $Tip1
@onready var tip2 : StaticBody2D = $Tip2
@onready var tip3 : StaticBody2D = $Tip3

# tentacle collision detectors
@onready var ray1 : RayCast2D = $Rays/Ray1
@onready var ray2 : RayCast2D = $Rays/Ray2
@onready var ray3 : RayCast2D = $Rays/Ray3

# tentacle visualisation
@onready var tentacle1 : Line2D = $Tentacles/Tentacle_1
@onready var tentacle2 : Line2D = $Tentacles/Tentacle_2
@onready var tentacle3 : Line2D = $Tentacles/Tentacle_3
#endregion

#region Public Variables
@export var force : float = 10.0 # player movement force
@export var rays : Array[RayCast2D] = []
@export var tentacles : Array[Line2D] = []
@export var targets : Array[StaticBody2D] = []
var speed : float = 10
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.global_position = spawn.position
	
	var c : int = 0
	for t in tentacles:
		tentacles[c].visible = false
		c += 1

func _physics_process(_delta: float) -> void:
	UpdateTentaclePositions(ray)
	
	var i : int = 0
	for t in tentacles:
		if t.visible:
			var dir = targets[i].global_position - player.global_position
			player.apply_central_force(dir * lerp(force, 0.0, _delta * speed))
		i += 1
	
	# Attach tentacle
	if Input.is_action_just_pressed("left_click"):
		var c : int = 0
		for t in tentacles:
			TentacleVisualiser(tentacles[c], rays[c], targets[c])
			c += 1

#region Tentacle System
func TentacleVisualiser(t: Line2D, r: RayCast2D, tip: StaticBody2D) -> void:
	if r.is_colliding():
		t.visible = true
		tip.position = r.get_collision_point()
		t.points[-1] = tip.position
	else:
		t.visible = false
		return

func UpdateTentaclePositions(obj: Node2D) -> void:
	obj.position = player.position
	obj.look_at(get_global_mouse_position())
	
	# root tentacle to player body
	for i in tentacles:
		i.points[0] = player.position
#endregion

#region Menu System
func _process(_delta: float) -> void:
	MenuSystem()

func MenuSystem() -> void:
	if Input.is_action_just_pressed("quit"):
		Quit()
	if Input.is_action_just_pressed("restart"):
		Restart()
	if Input.is_action_just_pressed("pause"):
		Pause()

func Restart() -> void:
	get_tree().reload_current_scene()

func Pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func Quit() -> void:
	get_tree().quit()
#endregion
