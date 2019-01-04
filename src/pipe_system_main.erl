-module(pipe_system_main).
-export([init/0,  write_json_file/1]).

init()->
    register(main_system, self()),
    survivor:start(),
    observer:start(),
    {ok, Pipe1} = resource_type:create(pipeTyp, []),
    {ok, PipeInst1} = pipeInst:create(self(), Pipe1),
    {ok, Pipe2} = resource_type:create(pipeTyp, []),
    {ok, PipeInst2} = pipeInst:create(self(), Pipe1),
    Data = jiffy:encode({[{ruben, heeft_een_grote_piemel}]}),
    write_json_file(Data).
    
    
write_json_file(Text)->
    file:write_file("../../priv/static/buizen_info.json", Text).