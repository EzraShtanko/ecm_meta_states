@icon("img/img_Icon_MetaStateResource_32x32px.png")
@tool
class_name MetaStateResource
extends Resource

signal updated

@export var update: float = 0.5:
	set(v): update = clampf(v, 0., 10.)
@export var effects: Array[MetaEffect] = []:
	set(v):
		effects = v
		effects.sort_custom(MetaStateResource.sort_by_priority)
		changed.emit()

@export_tool_button("Reset", "Back") var action_reset: Callable 			= func (): stats.clear()
@export_tool_button("Force Post", "2D") var action_force_post: Callable		= func (): post()

var stats: Array[mio.Stat]
var countdown: float = update
var flags := Flag.new()



class ReconfigBase extends mio.Reconfig:
	var x: MetaStateResource
	func _init(_x: MetaStateResource) -> void: x = _x
	func _process() -> void:
		for i in x.stats: x.run(i)
		x.changed.emit()
var reconfig_base: ReconfigBase = ReconfigBase.new(self)

func post(params: Dictionary = {}) -> void: 
	reconfig_base.post()
	_post(params)
func inflict(x: MetaEffect, params: Dictionary = {}) -> void:	
	if check(x.effect_name):
		var e: MetaEffect = 			efind(x.effect_name)
		if x._negates(e, params):		lift(e)
		else:							e._add(x.duplicate(), params)
	else:
		var xn = x.duplicate()
		effects.push_back(xn)
		effects.sort_custom(MetaStateResource.sort_by_priority)
		xn._inflict(self, params)
	changed.emit()
	post()
func lift(x: MetaEffect) -> void:
	if x in effects:
		x._lift(self)
		effects.erase(x)
		changed.emit()
		post()

func process(delta: float) -> void:
	reconfig_base.process()
	_process(delta)
	countdown -= delta
	if countdown <= 0.:
		for i in effects: if i: i._affect(self, update)
		countdown = update
		updated.emit()

# abstract methods of MetaStateResource class
func _post(_params: Dictionary = {}) -> void: pass
func _process(_delta: float) -> void: pass
# >>- - -->

# main stat configuring method
func run(x: mio.Stat) -> void: x.actual = effects.reduce( func (a: Variant, me: MetaEffect) : return me._factor(x.stat_name, a), x.target)
# >>- - -->


func find_by_name_effect(x: MetaEffect, s: StringName) -> bool: 		return x.effect_name == s 	if x else false
func find_by_name_stat(x: mio.Stat, s: StringName) -> bool: 			return x.stat_name == s 		if x else false
static func sort_by_priority(a: MetaEffect, b: MetaEffect) -> bool: 
	if not a: return false
	if not b: return true
	var idx_a: int = 128
	var idx_b: int = 128
	if a.effect_name in glss.EFFECT_CHAIN: idx_a = glss.EFFECT_CHAIN.find(a.effect_name)
	if b.effect_name in glss.EFFECT_CHAIN: idx_b = glss.EFFECT_CHAIN.find(b.effect_name)
	return idx_a < idx_b


func check(s: StringName) -> bool: return effects.any(find_by_name_effect.bind(s)) or stats.any(find_by_name_stat.bind(s))
func sfind(s: StringName) -> mio.Stat:
	var idx: int = stats.find_custom(find_by_name_stat.bind(s))
	if idx >= 0: return stats[idx]
	return null
func efind(s: StringName) -> MetaEffect:
	var idx: int = effects.find_custom(find_by_name_effect.bind(s))
	if idx >= 0: return effects[idx]
	return null
func make(s: StringName, v: Variant) -> void:
	if check(s): 
		sfind(s).target = v
	else:
		stats.push_back(mio.Stat.new(s, v))
		post()

func readf(s: StringName) -> float:			return sfind(s).actual if check(s) else 0.
func reads(s: StringName) -> String:			return sfind(s).actual if check(s) else ""
func readi(s: StringName) -> int:			return sfind(s).actual if check(s) else 0
func readb(s: StringName) -> bool:			return sfind(s).actual if check(s) else false
