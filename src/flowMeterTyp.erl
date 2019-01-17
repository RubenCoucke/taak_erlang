-module(flowMeterTyp).
-export([create/0, init/0, computeFlow/2]).
% -export([dispose/2, enable/2, new_version/2]).
% -export([get_initial_state/3, get_connections_list/2]). % use resource_type
% -export([update/3, execute/7, refresh/4, cancel/4, update/7, available_ops/2]). 

create() -> {ok, spawn(?MODULE, init, [])}.

init() -> 
	survivor:entry(flowMeterTyp_created),
	loop().

loop() -> 
	receive
		{initial_state, {MeterInst_Pid, {ResInst_Pid, RealWorldCmdFn}}, ReplyFn} ->
			{ok, [L | _ ] } = resource_instance:list_locations(ResInst_Pid),
			{ok, Fluidum} = location:get_Visitor(L),
			ReplyFn(#{pipeInst => ResInst_Pid, resInst => MeterInst_Pid, 
					  fluidum => Fluidum, rw_cmd => RealWorldCmdFn}), 
			loop();
		{measure_flow, State, ReplyFn} -> 
			#{rw_cmd := ExecFn} = State,
			ReplyFn(ExecFn()),
			loop(); 
		{estimate_flow, State, ReplyFn} -> 
			#{pipeInst := PipeInst_Pid} = State,
			#{resInst := ResInst_Pid} = State,
			#{circuit := C} = State,
			{ok, [L | _ ] } = resource_instance:list_locations(PipeInst_Pid),
			 %ReplyFn(Fluidum),
			% ReplyFn(C), 
			survivor:entry({estimateflow, for, C}), 
			Answer = computeFlow(C, ResInst_Pid), 
			survivor:entry({estimateflow, should, be, Answer}),
			ReplyFn(Answer),
			loop()
	end. 

computeFlow(ResCircuit, ResInst_Pid) -> 
 	Interval = {0, 10}, % ToDo >> discover upper bound for flow.
	{ok, InfluenceFnCircuit} = influence(ResCircuit, [], ResInst_Pid),
	survivor:entry(InfluenceFnCircuit),
	compute(Interval, InfluenceFnCircuit).

influence([H|T], Acc, ResInst_Pid) ->
	if
		H == ResInst_Pid->
			InflFn = fun(Flow) -> flow(Flow) end,
			survivor:entry({flow_computed_for, H, currentPid, ResInst_Pid}),
			
			influence(T, [ InflFn | Acc] , ResInst_Pid);
		true ->
			{ok, InflFn} = apply(resource_instance, get_flow_influence, [H]),
			survivor:entry({flow_computed_for, H, currentPid, ResInst_Pid}),
			
			influence(T, [ InflFn | Acc ] , ResInst_Pid)
	end;

influence([], Acc, ResInst_Pid) -> {ok, Acc}. 

compute({Low, High}, _InflFnCircuit) when (High - Low) < 1 -> 
	%Todo convergentiewaarde instelbaar maken. 
	(Low + High) / 2 ;
	
compute({Low, High}, InflFnCircuit) ->
	L = eval(Low, InflFnCircuit, 0),
	H = eval(High, InflFnCircuit, 0),
	L = eval(Low, InflFnCircuit, 0),
	H = eval(High, InflFnCircuit, 0),
	Mid = (H + L) / 2, M = eval(Mid, InflFnCircuit, 0),
	if 	M > 0 -> 
			compute({Low, Mid}, InflFnCircuit);
        true -> % works as an 'else' branch
            compute({Mid, High}, InflFnCircuit)
    end.

	
eval(Flow, [Fn | RemFn] , Acc) ->
	eval(Flow, RemFn, Acc + Fn(Flow));

eval(_Flow, [], Acc) -> Acc. 

flow(N) -> - 0.01 * N.