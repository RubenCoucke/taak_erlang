{application, 'buizen', [
	{description, "Taak erlang"},
	{vsn, "0.1.0"},
	{modules, ['buizen_app','buizen_display_handler','buizen_sup','connector','flowMeterInst','flowMeterTyp','fluidumInst','fluidumTyp','location','msg','pipeInst','pipeTyp','pipe_system_main','pumpInst','pumpTyp','resource_instance','resource_type','survivor']},
	{registered, [buizen_sup]},
	{applications, [kernel,stdlib,cowboy,jiffy]},
	{mod, {buizen_app, []}},
	{env, []}
]}.