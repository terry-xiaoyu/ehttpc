%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(ecpool_pool_sup).

-behaviour(supervisor).

%% API
-export([start_link/2]).

%% Supervisor callbacks
-export([init/1]).

start_link(Pool, Opts) ->
    supervisor:start_link(?MODULE, [Pool, Opts]).

init([Pool, Opts]) ->
    Specs = [#{id => pool,
               start => {ehttpc_pool, start_link, [Pool, Opts]},
               restart => transient,
               shutdown => 5000,
               type => worker,
               modules => [ehttpc_pool]},
             #{id => worker_sup,
               start => {ehttpc_worker_sup, start_link, [Pool, Opts]},
               restart => transient,
               shutdown => infinity,
               type => supervisor,
               modules => [ehttpc_worker_sup]}],
    {ok, {{one_for_all, 10, 100}, Specs}}.