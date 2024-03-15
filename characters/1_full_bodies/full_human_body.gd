# Fully modular human body capable of simple ragdoll mechanics
# Consists of a head, body, hands, and feet
# Body part scenes should be added as children to their respective pivot
#
# This scene exposes common attachment points like the head pivot for
# cameras, which can be accessed by a parent frame or character node

extends Node3D

# Preload all party type meshes
const BODY_ARRAY: Array[PackedScene] = \
[ preload("res://characters/2_parts_bodies/human_body_1.tscn"), \
preload("res://characters/2_parts_bodies/human_body_2.tscn")]

# Synced variables
@export var body_type: int = 0
@export var body_top_color: Color = Color(1, 1, 1, 1)
@export var body_bottom_color: Color = Color(1, 1, 1, 1)

# Exposed nodes
@onready var skeleton: Skeleton3D = $Skeleton3D
@onready var core_bone: PhysicalBone3D = $Skeleton3D/CoreBone
@onready var head_pivot: Node3D = $Skeleton3D/CoreBone/HeadPivot
@onready var body_pivot: Node3D = $Skeleton3D/CoreBone/BodyPivot
@onready var left_hand: Node3D = $Skeleton3D/CoreBone/LeftHandPivot
@onready var right_hand: Node3D = $Skeleton3D/CoreBone/RightHandPivot
@onready var left_foot: Node3D = $Skeleton3D/CoreBone/LeftFootPivot
@onready var right_foot: Node3D = $Skeleton3D/CoreBone/RightFootPivot

func _ready() -> void:
	# Set up synced vars only on the authority, it will
	# then push it to other peers
	if is_multiplayer_authority():
		body_type = randi_range(0, BODY_ARRAY.size() - 1)
		body_top_color = Color(randf(), randf(), randf(), 1)
		body_bottom_color = Color(randf(), randf(), randf(), 1)

	var body_node = BODY_ARRAY[body_type].instantiate()
	body_pivot.add_child(body_node)

#TODO Find a way to apply synced colors without this timer hack
func _on_color_timer_timeout():
	update_colors()

func update_colors() -> void:
	var body_top_material = StandardMaterial3D.new()
	var body_bottom_material = StandardMaterial3D.new()
	body_top_material.set_albedo(body_top_color)
	body_bottom_material.set_albedo(body_bottom_color)

	var body_mesh: MeshInstance3D = body_pivot.get_child(0).get_child(0)
	body_mesh.set_surface_override_material(0, body_top_material)
	body_mesh.set_surface_override_material(1, body_bottom_material)


