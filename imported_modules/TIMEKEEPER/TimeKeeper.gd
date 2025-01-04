extends WorldEnvironment

@onready var HEAVENLY_BODIES = $heavenly_bodies as Node3D
@onready var STATIC_LIGHTS = $static_lights as Node3D
enum {AM, PM}
enum {HOUR, MINUTE, PERIOD, DAY}

func _ready():
	get_parent().world_tick.connect(process_world_tick)

func process_world_tick(time: Vector4i):
	var hour =  12 - time[HOUR] + time[PERIOD]*12 
	HEAVENLY_BODIES.rotation_degrees.z = hour*(360/24) - time[MINUTE]*(15.0/60.0)
	
	var fade_light = STATIC_LIGHTS.get_child(time[PERIOD]) as DirectionalLight3D
	if time[HOUR] == 5:
		var rising_light = HEAVENLY_BODIES.get_child(time[PERIOD]) as DirectionalLight3D
		rising_light.light_energy = time[MINUTE]/60.0
		fade_light.light_energy = time[MINUTE]*2/60.0
	elif time[HOUR] == 6:
		var setting_light = HEAVENLY_BODIES.get_child(not time[PERIOD]) as DirectionalLight3D
		setting_light.light_energy = 1-time[MINUTE]/60.0
		fade_light.light_energy = 2-time[MINUTE]*2/60.0
	else: 
		STATIC_LIGHTS.get_child(0).light_energy = 0
		STATIC_LIGHTS.get_child(1).light_energy = 0
