-module(pipe_system_main).
-export([init/0,  write_json_file/1]).

init()->
    register(main_system, self()),
    survivor:start(),
    observer:start(),
    %buizen maken
    {ok, PipeType} = resource_type:create(pipeTyp, []),
    {ok, Pipe1} = pipeInst:create(self(), PipeType),
    {ok, Pipe2} = pipeInst:create(self(), PipeType),
    {ok, Pipe3} = pipeInst:create(self(), PipeType),
    {ok, Pipe4} = pipeInst:create(self(), PipeType),
    %{ok, Pipe5} = pipeInst:create(self(), PipeType),
    %{ok, Pipe6} = pipeInst:create(self(), PipeType),
    %{ok, Pipe7} = pipeInst:create(self(), PipeType),
    %{ok, Pipe8} = pipeInst:create(self(), PipeType),

    %warmtewisselaar maken
    %{ok, Warmtewisselaar} = heatExchangerTyp:create(),
    %{ok, WarmtewisselaarInst} = heatExchangerInst:create(self(), Warmtewisselaar, PipeInst1, WarmtewisselaarInst2),

    %{ok, Warmtewisselaar2} = heatExchangerTyp:create(),
    %{ok, WarmtewisselaarInst2} = heatExchangerInst:create(self(), Warmtewisselaar2, PipeInst2, WarmtewisselaarInst),

    %debietmeter maken
    {ok, DebietmeterType} = resource_type:create(flowMeterTyp, []),
    {ok, Debietmeter} = flowMeterInst:create(self(), DebietmeterType, Pipe1, 0),
    
    %pomp maken
    {ok, PompType} = resource_type:create(pumpTyp, []),
    {ok, Pomp} = pumpInst:create(self(), PompType, Pipe2, 0),

    %verbindingen maken
    {ok, [PompConnector1, PompConnector2]} = msg:get(Pomp, get_connectors),
    {ok, [DebietmeterConnector1, DebietmeterConnector2]} = msg:get(Debietmeter, get_connectors),
    {ok, [Pipe3Connector1, Pipe3Connector2]} = msg:get(Pipe3, get_connectors),
    {ok, [Pipe4Connector1, Pipe4Connector2]} = msg:get(Pipe4, get_connectors),

    connector:connect(PompConnector1, Pipe3Connector1),
    connector:connect(Pipe3Connector2, DebietmeterConnector1),
    connector:connect(DebietmeterConnector2, Pipe4Connector1),
    connector:connect(Pipe4Connector2, PompConnector1),

    %fluidum
    FluidumType = fluidumTyp:create(),
    {ok, Fluidum} = fluidumInst:create(PompConnector1, FluidumType),

    {ok, [PompLocatie]} = msg:get(Pomp, get_locations),
    {ok, [DebietmeterLocatie]} = msg:get(Debietmeter, get_locations),
    {ok, [Buis3Locatie]} = msg:get(Pipe3, get_locations),
    {ok, [Buis4Locatie]} = msg:get(Pipe4, get_locations),
    
    location:departure(PompLocatie),
    %survivor:entry(flowMeterInst:estimate_flow(Debietmeter)),


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
                }
            },
            <<"Verbindingen">> => [
                [list_to_atom(pid_to_list(PompConnector1)), list_to_atom(pid_to_list(Pipe3Connector1))],
                [list_to_atom(pid_to_list(Pipe3Connector2)), list_to_atom(pid_to_list(DebietmeterConnector1))],
                [list_to_atom(pid_to_list(DebietmeterConnector2)), list_to_atom(pid_to_list(Pipe4Connector1))],
                [list_to_atom(pid_to_list(Pipe4Connector2)), list_to_atom(pid_to_list(PompConnector2))]
            ]
            
        }
    , Options),
                        
    write_json_file(Data).
    
    
write_json_file(Text)->
    file:write_file("../../priv/static/buizen_info.json", Text).


%loop maken