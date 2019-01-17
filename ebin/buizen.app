{application, 'buizen', [
	{description, "Taak erlang"},
	{vsn, "0.1.0"},
	{modules, ['aggregate_instance','aggregate_type','buizen_app','buizen_display_handler','buizen_sup','connector','demo1','demo2','demo3','demo4','flowMeterInst','flowMeterTyp','fluidumInst','fluidumTyp','heatExchangeLink','heatExchangerInst','heatExchangerTyp','location','msg','pipeInst','pipeTyp','pipe_system_main','pumpInst','pumpTyp','resource_instance','resource_type','simpleThermalCircuit_instance','simpleThermalCircuit_type','survivor','survivor2','test1']},
	{registered, [buizen_sup]},
	{applications, [kernel,stdlib,cowboy,jiffy]},
	{mod, {buizen_app, []}},
	{env, []}
]}.