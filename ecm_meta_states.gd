@tool
extends EditorPlugin

#minor change comment


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	add_custom_type("MetaEffect", "Resource", preload("meta_effect.gd"), preload("img/img_Icon_MetaEffect_32x32px.png"))
	add_custom_type("MetaStateResource", "Resource", preload("meta_state_resource.gd"), preload("img/img_Icon_MetaStateResource_32x32px.png"))


func _exit_tree() -> void:
	remove_custom_type("MetaEffect")
	remove_custom_type("MetaStateResource")
