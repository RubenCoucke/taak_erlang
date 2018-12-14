-module(pipe_system_main).
-export([init/0]).

init()->
    {ok, Pipe1} = resource_type:create(pipeTyp, []),
    {ok, PipeInst1} = pipeInst:create(self(), Pipe1).