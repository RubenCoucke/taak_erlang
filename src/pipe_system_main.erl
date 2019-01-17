-module(pipe_system_main).
-export([create/0, init/0]).

create()->
    
    {ok, spawn(?MODULE, init, [])}.

init()->
    survivor:start(),
    observer:start(),
    survivor:entry({program_pid, self()}),
    %buizen maken
    {ok, PipeType} = resource_type:create(pipeTyp, []),
    {ok, Pipe1} = pipeInst:create(self(), PipeType),
    {ok, Pipe2} = pipeInst:create(self(), PipeType),
    {ok, Pipe3} = pipeInst:create(self(), PipeType),
    {ok, Pipe4} = pipeInst:create(self(), PipeType),
    {ok, Pipe5} = pipeInst:create(self(), PipeType),
    {ok, Pipe6} = pipeInst:create(self(), PipeType),
    {ok, Pipe7} = pipeInst:create(self(), PipeType),
    %{ok, Pipe8} = pipeInst:create(self(), PipeType),

   
    %debietmeter maken
    {ok, DebietmeterType} = resource_type:create(flowMeterTyp, []),
    {ok, Debietmeter} = flowMeterInst:create(self(), DebietmeterType, Pipe1, fun() -> no_data end),
    
    %pomp maken
    RWCmdFn = fun(Cmd) -> survivor:entry({pumpCmd, Cmd, self()}) end,
    {ok, PompType} = resource_type:create(pumpTyp, []),
    {ok, Pomp} = pumpInst:create(self(), PompType, Pipe2, RWCmdFn),

    %warmtewisselaar maken

    HE_link_spec = #{delta => 0.9},
    {ok, WarmtewisselaarType} = resource_type:create(heatExchangerTyp, []),
    {ok, Warmtewisselaar1} = heatExchangerInst:create(self(), WarmtewisselaarType, Pipe5, HE_link_spec),
    {ok, Warmtewisselaar2} = heatExchangerInst:create(self(), WarmtewisselaarType, Pipe6, HE_link_spec),

    %verbindingen maken
    {ok, [PompConnector1, PompConnector2]} = msg:get(Pomp, get_connectors),
    {ok, [DebietmeterConnector1, DebietmeterConnector2]} = msg:get(Debietmeter, get_connectors),
    {ok, [Pipe3Connector1, Pipe3Connector2]} = msg:get(Pipe3, get_connectors),
    {ok, [Pipe4Connector1, Pipe4Connector2]} = msg:get(Pipe4, get_connectors),
    {ok, [Warmtewisselaar1Connector1, Warmtewisselaar1Connector2]} = msg:get(Warmtewisselaar1, get_connectors),
    {ok, [Warmtewisselaar2Connector1, Warmtewisselaar2Connector2]} = msg:get(Warmtewisselaar2, get_connectors),
    {ok, [Pipe7Connector1, Pipe7Connector2]} = msg:get(Pipe7, get_connectors),

    %connector:connect(PompConnector1, Pipe3Connector1),
    %connector:connect(Pipe3Connector2, DebietmeterConnector1),
    %%connector:connect(DebietmeterConnector2, Pipe4Connector1),
    %connector:connect(Pipe4Connector2, Warmtewisselaar1Connector1),
    %connector:connect(Warmtewisselaar1Connector2, Warmtewisselaar2Connector1),
    %connector:connect(Warmtewisselaar2Connector2, Pipe7Connector1),
    %connector:connect(Pipe7Connector2, PompConnector2),

    {ok, AggrTyp_Pid} = simpleThermalCircuit_type:create(),
	{ok, AggrInst_Pid} = simpleThermalCircuit_instance:create(self(), AggrTyp_Pid, [Pomp, Pipe3, Debietmeter, Pipe4,Warmtewisselaar1, Warmtewisselaar2, Pipe7]),

    timer:sleep(100),

    %fluidum
    {ok, FluidumType} = fluidumTyp:create(),
    {ok, Fluidum} = fluidumInst:create(PompConnector1, FluidumType),


    timer:sleep(1000),
    fluidumInst:load_circuit(Fluidum), 
    timer:sleep(1000),
    pumpInst:switch_on(Pomp), 

    {ok, Circuit} = msg:get(AggrInst_Pid, get_circuit_list),

    msg:get(Debietmeter, update_circuit, Circuit),	


    {ok, [PompLocatie]} = msg:get(Pomp, get_locations),
    {ok, [DebietmeterLocatie]} = msg:get(Debietmeter, get_locations),
    {ok, [Buis3Locatie]} = msg:get(Pipe3, get_locations),
    {ok, [Buis4Locatie]} = msg:get(Pipe4, get_locations),
    {ok, [WW1Locatie]} = msg:get(Warmtewisselaar1, get_locations),
    {ok, [WW2Locatie]} = msg:get(Warmtewisselaar2, get_locations),
    {ok, [Buis7Locatie]} = msg:get(Pipe7, get_locations),
    
    


    %data schrijven naar json file
    Options = [pretty],
    Data = jiffy:encode(#
        {
            <<"Pomp (buis 1)">> => #{
                <<"locatie">> => list_to_atom(pid_to_list(PompLocatie)),
                <<"verbindingen">> => #{
                    <<"verbinding1">> => list_to_atom(pid_to_list(PompConnector1)),
                    <<"verbinding2">> => list_to_atom(pid_to_list(PompConnector2))
                }
            },
            <<"Debietmeter (buis 2)">> => #{
                <<"locatie">> => list_to_atom(pid_to_list(DebietmeterLocatie)),
                <<"verbindingen">> => #{
                    <<"verbinding1">> => list_to_atom(pid_to_list(DebietmeterConnector1)),
                    <<"verbinding2">> => list_to_atom(pid_to_list(DebietmeterConnector2))
                }
            },
            <<"Warmtewisselaar 1 (buis 5)">> => #{
                <<"locatie">> => list_to_atom(pid_to_list(WW1Locatie)),
                <<"verbindingen">> => #{
                    <<"verbinding1">> => list_to_atom(pid_to_list(Warmtewisselaar1Connector1)),
                    <<"verbinding2">> => list_to_atom(pid_to_list(Warmtewisselaar1Connector2))
                }
            },
            <<"Warmtewisselaar 2 (buis 6)">> => #{
            <<"locatie">> => list_to_atom(pid_to_list(WW2Locatie)),
                <<"verbindingen">> => #{
                     <<"verbinding1">> => list_to_atom(pid_to_list(Warmtewisselaar2Connector1)),
                    <<"verbinding2">> => list_to_atom(pid_to_list(Warmtewisselaar2Connector2))
                }
            },
            <<"Buizen">> => #{
                <<"Buis 3">> => #{
                    <<"locatie">> => list_to_atom(pid_to_list(Buis3Locatie)),
                    <<"verbindingen">> => #{
                        <<"verbinding1">> => list_to_atom(pid_to_list(Pipe3Connector1)),
                        <<"verbinding2">> => list_to_atom(pid_to_list(Pipe3Connector2))
                    }
                },
                <<"Buis 4">> => #{
                    <<"locatie">> => list_to_atom(pid_to_list(Buis4Locatie)),
                    <<"verbindingen">> => #{
                        <<"verbinding1">> => list_to_atom(pid_to_list(Pipe4Connector1)),
                        <<"verbinding2">> => list_to_atom(pid_to_list(Pipe4Connector2))
                    }
                },
                <<"Buis 7">> => #{
                    <<"locatie">> => list_to_atom(pid_to_list(Buis7Locatie)),
                    <<"verbindingen">> => #{
                        <<"verbinding1">> => list_to_atom(pid_to_list(Pipe7Connector1)),
                        <<"verbinding2">> => list_to_atom(pid_to_list(Pipe7Connector2))
                    }
                }
            
            },
            <<"Verbindingen">> => [
                [list_to_atom(pid_to_list(PompConnector2)), list_to_atom(pid_to_list(Pipe3Connector1))],
                [list_to_atom(pid_to_list(Pipe3Connector2)), list_to_atom(pid_to_list(DebietmeterConnector1))],
                [list_to_atom(pid_to_list(DebietmeterConnector2)), list_to_atom(pid_to_list(Pipe4Connector1))],
                [list_to_atom(pid_to_list(Pipe4Connector2)), list_to_atom(pid_to_list(Warmtewisselaar1Connector1))],
                [list_to_atom(pid_to_list(Warmtewisselaar1Connector2)), list_to_atom(pid_to_list(Warmtewisselaar2Connector1))],
                [list_to_atom(pid_to_list(Warmtewisselaar2Connector2)), list_to_atom(pid_to_list(Pipe7Connector1))],
                [list_to_atom(pid_to_list(Pipe7Connector2)), list_to_atom(pid_to_list(PompConnector1))]
            ]
            
        }
    , Options),
                        
    write_json_file_circuit(Data),
    loop(Circuit).
    
    
write_json_file_circuit(Text)->
    survivor:entry({written, file, file:write_file("../../_rel/buizen_release/lib/buizen-0.1.0/priv/static/buizen_info.json", Text)}).
    

write_json_file_flow(Text)->
    survivor:entry({written, file, file:write_file("../../_rel/buizen_release/lib/buizen-0.1.0/priv/static/flow_info.json", Text)}).


loop(Circuit) -> 
    receive
        {estimate_flow, ReplyFn} -> 
            survivor:entry(Circuit),
            [_, _, Debietmeter, _, _, _, _] = Circuit,
            {ok, Flow} = msg:get(Debietmeter, estimate_flow),
			Data = jiffy:encode(#{
                <<"Flow">> => Flow
            }),
            write_json_file_flow(Data),
            ReplyFn({flow, updated}),
			loop(Circuit);
        {measure_flow, ReplyFn} -> 
            survivor:entry(Circuit),
            [_, _, Debietmeter, _, _, _, _] = Circuit,
            {ok, Flow} = msg:get(Debietmeter, measure_flow),
			Data = jiffy:encode(#{
                <<"Flow">> => Flow
            }),
            write_json_file_flow(Data),
            ReplyFn({flow, updated}),
			loop(Circuit);
        {turn_on_pump, ReplyFn} ->      
            [Pomp, _, _, _, _, _, _] = Circuit,
            pumpInst:switch_on(Pomp), 
            ReplyFn({pump, turned, on}),
            loop(Circuit);
        {turn_off_pump, ReplyFn} ->      
            [Pomp, _, _, _, _, _, _] = Circuit,
            pumpInst:switch_off(Pomp), 
            ReplyFn({pump, turned, off}),
            
            loop(Circuit);
        {get_temp, ReplyFn} ->      
            [_, _, Debietmeter, _, Warmtewisselaar1, _, _] = Circuit,
            {ok, {_,Temp}} = heatExchangerInst:temp_influence(Warmtewisselaar1),
            {ok, Flow} = msg:get(Debietmeter, estimate_flow),
            Temp1 = lists:foldl(Temp, 0, [Flow, 10]), 
            ReplyFn({temp, Temp1}),
            loop(Circuit)
    end.
        
