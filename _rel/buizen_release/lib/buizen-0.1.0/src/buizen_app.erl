-module(buizen_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).



start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, buizen, "index.html"}},
			{"/buizen", buizen_display_handler, []},
			{"/static/[...]", cowboy_static, {priv_dir, buizen, "static"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),

	buizen_sup:start_link().

stop(_State) ->
	ok.
