@icon("img/img_Icon_MetaEffect_32x32px.png")
@abstract
@tool
class_name MetaEffect
extends Resource

var effect_name			: StringName 		= &"untitled_effect"
var immediate			: bool 				= false

@abstract func _init()

func _inflict(_x: MetaStateResource, _params: Dictionary = {}) -> void: 		pass
func _affect(_x: MetaStateResource, _delta: float) -> void: 					pass
func _lift(_x: MetaStateResource) -> void: 									pass
func _add(_me: MetaEffect, _params: Dictionary = {}) -> void: 				pass
func _factor(_s: StringName, v: Variant) -> Variant: 							return v
func _negates(_me: MetaEffect, _params: Dictionary = {}) -> bool: 			return false
