-module(pipe_system_main).
-export([init/0]).

init()->
    register(main_system, self()),
    survivor:start(),
    observer:start(),
    {ok, Pipe1} = resource_type:create(pipeTyp, []),
    {ok, PipeInst1} = pipeInst:create(self(), Pipe1).
    