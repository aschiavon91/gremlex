<p align="center"><img src="logo.png"></img></p>

[![Build Status](https://travis-ci.com/Revmaker/gremlex.svg?branch=master)](https://travis-ci.com/Revmaker/gremlex)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Gremlex

An Elixir client for Apache TinkerPop™ aka [Gremlin](http://tinkerpop.apache.org/gremlin.html).

Gremlex does not support all functions (yet). It is pretty early on in it's development. But you can always use raw Gremlin queries by using `Client.query("<Insert gremlin query>")`

## Installation

Install from Hex.pm:

```elixir
def deps do
  [
    {:gremlex, "~> 0.3"}
  ]
end
```

## Examples

#### Basic Usage
The two main modules that you'll want to use are `Gremlex.Graph` and `Gremlex.Client`.

`Gremlex.Graph` is the module that hosts all the functions needed to build a Gremlin query.
The DSL is a simple set of functions that carries over a graph for every step. Once you've
defined your query, you can simply call `Gremlex.Client.query/1` to perform it.

```elixir
iex(1)> alias Gremlex.Graph
Gremlex.Graph
iex(2)> alias Gremlex.Client
Gremlex.Client
iex(3)> Graph.g() |> Graph.v() |> Client.query
{:ok,
 [
   %Gremlex.Vertex{
     id: 1,
     label: "person",
     properties: %{age: [29], name: ["marko"]}
   }
 ]}
```

#### Gremlin Query to Gremlex
This gremlin query:
```
g.V().has("name","marko")
  .out("knows")
  .out("knows")
  .values("name")
```
Would translate in Gremlex to:
```elixir
Graph.g()
|> Graph.v()
|> Graph.has("name", "marko")
|> Graph.out("knows")
|> Graph.out("knows")
|> Graph.values("name")
|> Client.query
```

#### Raw Queries
```elixir
Client.query("""
  g.V().match(
    __.as("a").out("knows").as("b"),
    __.as("a").out("created").as("c"),
    __.as("b").out("created").as("c"),
    __.as("c").in("created").count().is(2)
  )
  .select("c").by("name")
""")
```

## Configuration
You can configure Gremlex by adding the following to your `config.exs`:

```elixir
config :gremlex,
  host: "127.0.0.1",
  port: 8182,
  path: "/gremlin",
  pool_size: 10,
  secure: false
  ping_delay: 60_000
```

Gremlex uses [confex](https://github.com/Nebo15/confex), so that you can easily define
your configuration to use environment variables when it comes time to deploying. To do so,
simply have the parameters that need to be dynamically read at run time set to `{:SYSTEM, "ENV_VAR_NAME"}`.

### Parameters
* `host`: Gremlin host to connect to (defaults to "127.0.0.1")
* `port`: Port Gremlin is listening to on host (defaults to 8182)
* `path`: Websocket path to Gremlin (defaults to "/gremlin")
* `pool_size`: The number of connections to keep open in the pool (defaults to 10)
* `secure`: Set to `true` to connect to a server with SSL enabled
* `ping_delay`: Delay in milliseconds to send a pong frame to the server. If 0, then a pong frame won't be scheduled. (defaults to 0)

## Contributing

    $ git clone https://github.com/Revmaker/gremlex.git
    $ cd gremlex
    $ mix deps.get
    $ mix test

Once you've made your additions and `mix test` passes, go ahead and open a PR!
Note: Please make sure you run `mix format` on the touched files :)
