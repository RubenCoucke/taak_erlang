PROJECT = buizen
PROJECT_DESCRIPTION = Taak erlang
PROJECT_VERSION = 0.1.0

DEPS = cowboy jiffy
dep_cowboy_commit = 2.6.1
dep_jiffy = git https://github.com/davisp/jiffy master

DEP_PLUGINS = cowboy

include erlang.mk
