extends Area3D

func _ready(): body_entered.connect(hurt)

func hurt(node: Node3D): if node.is_in_group("mortal"): node.take_damage(50)
