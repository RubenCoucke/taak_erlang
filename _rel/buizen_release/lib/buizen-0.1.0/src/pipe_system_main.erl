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
    %{ok, Pipe3} = pipeInst:create(self(), PipeType),
    %{ok, Pipe4} = pipeInst:create(self(), PipeType),
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
    connector:connect(PompConnector1, DebietmeterConnector1),
    connector:connect(PompConnector2, DebietmeterConnector2),
    %fluidum
    FluidumType = fluidumTyp:create(),
    {ok, Fluidum} = fluidumInst:create(PompConnector1, FluidumType),

    {ok, [PompLocatie]} = msg:get(Pomp, get_locations),
    location:departure(PompLocatie),
    %survivor:entry(flowMeterInst:estimate_flow(Debietmeter)),

    Data = jiffy:encode({[{ruben, heeft_een_grote_piemel}]}),
    write_json_file(Data).
    
    
write_json_file(Text)->
    file:write_file("../../priv/static/buizen_info.json", Text).


%loop maken