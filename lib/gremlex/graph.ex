defmodule Gremlex.Graph do
  @moduledoc """
  Functions for traversing and mutating the Graph.

  Graph operations are stored in a queue which can be created with `g/0`.
  Mosts functions return the queue so that they can be chained together
  similar to how Gremlin queries work.

  Example:
  ```
  g.V(1).values("name")
  ```
  Would translate to
  ```
  g |> v(1) |> values("name")
  ```

  Note: This module doesn't actually execute any queries, it just allows you to build one.
  For query execution see `Gremlex.Client.query/1`
  """
  alias :queue, as: Queue

  @type t :: {[], []}
  @default_namespace_property "namespace"
  @default_namespace "gremlex"

  @doc """
  Start of graph traversal. All graph operations are stored in a queue.
  """
  @spec g :: Gremlex.Graph.t()
  def g, do: Queue.new()

  @spec anonymous :: Gremlex.Graph.t()
  def anonymous do
    enqueue(Queue.new(), "__", [])
  end

  @doc """
  Appends an addV command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_v(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_v(graph, id) do
    enqueue(graph, "addV", [id])
  end

  @doc """
  Appends an addE command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec add_e(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_e(graph, edge) do
    enqueue(graph, "addE", [edge])
  end

  @doc """
  Appends an aggregate command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec aggregate(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def aggregate(graph, aggregate) do
    enqueue(graph, "aggregate", aggregate)
  end

  @spec barrier(Gremlex.Graph.t(), non_neg_integer()) :: Gremlex.Graph.t()
  def barrier(graph, max_barrier_size) do
    enqueue(graph, "barrier", max_barrier_size)
  end

  @spec barrier(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def barrier(graph) do
    enqueue(graph, "barrier", [])
  end

  @doc """
  Appends a coin command to the traversal. Takes in a graph and a probability
  modifier as parameters.
  Returns a graph to allow chaining.
  """
  @spec coin(Gremlex.Graph.t(), Float.t()) :: Gremlex.Graph.t()
  def coin(graph, probability) do
    enqueue(graph, "coin", probability)
  end

  @spec has_label(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def has_label(graph, label) do
    enqueue(graph, "hasLabel", [label])
  end

  @spec has(Gremlex.Graph.t(), any(), any()) :: Gremlex.Graph.t()
  def has(graph, key, value) do
    enqueue(graph, "has", [key, value])
  end

  @spec key(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def key(graph) do
    enqueue(graph, "key", [])
  end

  @doc """
  Appends property command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec property(Gremlex.Graph.t(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, key, value) do
    enqueue(graph, "property", [key, value])
  end

  @spec property(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def property(graph, key) do
    enqueue(graph, "property", [key])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :single, key, value) do
    enqueue(graph, "property", [:single, key, value])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :list, key, value) do
    enqueue(graph, "property", [:list, key, value])
  end

  @spec property(Gremlex.Graph.t(), atom(), String.t(), any()) :: Gremlex.Graph.t()
  def property(graph, :set, key, value) do
    enqueue(graph, "property", [:set, key, value])
  end

  @doc """
  Appends properties command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec properties(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def properties(graph, key) do
    enqueue(graph, "properties", [key])
  end

  @spec properties(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def properties(graph) do
    enqueue(graph, "properties", [])
  end

  @doc """
  Appends the store command to the traversal. Takes in a graph and the name of
  the side effect key that will hold the aggregate.
  Returns a graph to allow chaining.
  """
  @spec store(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def store(graph, store) do
    enqueue(graph, "store", store)
  end

  @spec cap(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def cap(graph, cap) do
    enqueue(graph, "cap", cap)
  end

  @doc """
  Appends valueMap command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec value_map(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def value_map(graph) do
    enqueue(graph, "valueMap", [])
  end

  @spec value_map(Gremlex.Graph.t(), Boolean.t()) :: Gremlex.Graph.t()
  def value_map(graph, value) when is_boolean(value) do
    enqueue(graph, "valueMap", value)
  end

  @spec value_map(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def value_map(graph, value) when is_binary(value) do
    enqueue(graph, "valueMap", [value])
  end

  @spec value_map(Gremlex.Graph.t(), list(String.t())) :: Gremlex.Graph.t()
  def value_map(graph, values) when is_list(values) do
    enqueue(graph, "valueMap", values)
  end

  @doc """
  Appends values command to the traversal.
  Returns a graph to allow chaining.
  """
  @spec values(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def values(graph, key) do
    enqueue(graph, "values", [key])
  end

  @doc """
  Appends values the `V` command allowing you to select a vertex.
  Returns a graph to allow chaining.
  """
  @spec v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def v({h, t} = graph) when is_list(h) and is_list(t) do
    enqueue(graph, "V", [])
  end

  @spec v(number()) :: Gremlex.Vertex.t()
  def v(id) do
    %Gremlex.Vertex{id: id, label: ""}
  end

  @spec v(Gremlex.Graph.t(), Gremlex.Vertex.t()) :: Gremlex.Graph.t()
  def v(graph, %Gremlex.Vertex{id: id}) do
    enqueue(graph, "V", [id])
  end

  @doc """
  Appends values the `V` command allowing you to select a vertex.
  Returns a graph to allow chaining.
  """
  @spec v(Gremlex.Graph.t(), number()) :: Gremlex.Graph.t()
  def v(graph, id) when is_number(id) or is_binary(id) do
    enqueue(graph, "V", [id])
  end

  @spec v(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def v(graph, id) do
    enqueue(graph, "V", id)
  end

  @spec in_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def in_e(graph) do
    enqueue(graph, "inE", [])
  end

  @spec in_e(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def in_e(graph, edges) do
    enqueue(graph, "inE", edges)
  end

  @spec out_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def out_e(graph) do
    enqueue(graph, "outE", [])
  end

  @spec out_e(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def out_e(graph, edges) do
    enqueue(graph, "outE", edges)
  end

  @spec out(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def out(graph) do
    enqueue(graph, "out", [])
  end

  @spec out(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def out(graph, labels) do
    enqueue(graph, "out", labels)
  end

  @spec in_(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def in_(graph, edge) do
    enqueue(graph, "in", [edge])
  end

  @spec in_(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def in_(graph) do
    enqueue(graph, "in", [])
  end

  @spec or_(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def or_(graph) do
    enqueue(graph, "or", [])
  end

  @spec and_(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def and_(graph) do
    enqueue(graph, "and", [])
  end

  @spec in_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def in_v(graph) do
    enqueue(graph, "inV", [])
  end

  @spec in_v(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def in_v(graph, labels) do
    enqueue(graph, "inV", labels)
  end

  @spec out_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def out_v(graph) do
    enqueue(graph, "outV", [])
  end

  @spec out_v(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def out_v(graph, labels) do
    enqueue(graph, "outV", labels)
  end

  @spec both(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both(graph) do
    enqueue(graph, "both", [])
  end

  @spec both(Gremlex.Graph.t(), List.t()) :: Gremlex.Graph.t()
  def both(graph, labels) when is_list(labels) do
    enqueue(graph, "both", labels)
  end

  @spec both(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def both(graph, label) do
    enqueue(graph, "both", [label])
  end

  @spec both_e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both_e(graph) do
    enqueue(graph, "bothE", [])
  end

  @spec both_e(Gremlex.Graph.t(), String.t() | List.t()) :: Gremlex.Graph.t()
  def both_e(graph, labels) do
    enqueue(graph, "bothE", labels)
  end

  @spec both_v(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def both_v(graph) do
    enqueue(graph, "bothV", [])
  end

  @spec both_v(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def both_v(graph, labels) do
    enqueue(graph, "bothV", labels)
  end

  @spec dedup(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def dedup(graph) do
    enqueue(graph, "dedup", [])
  end

  @spec to(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def to(graph, target) do
    enqueue(graph, "to", [target])
  end

  @spec has_next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def has_next(graph) do
    enqueue(graph, "hasNext", [])
  end

  @spec next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def next(graph) do
    enqueue(graph, "next", [])
  end

  @spec next(Gremlex.Graph.t(), number()) :: Gremlex.Graph.t()
  def next(graph, numberOfResults) do
    enqueue(graph, "next", [numberOfResults])
  end

  @spec try_next(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def try_next(graph) do
    enqueue(graph, "tryNext", [])
  end

  @spec to_list(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_list(graph) do
    enqueue(graph, "toList", [])
  end

  @spec to_set(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_set(graph) do
    enqueue(graph, "toSet", [])
  end

  @spec to_bulk_set(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def to_bulk_set(graph) do
    enqueue(graph, "toBulkSet", [])
  end

  @spec drop(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def drop(graph) do
    enqueue(graph, "drop", [])
  end

  @spec iterate(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def iterate(graph) do
    enqueue(graph, "iterate", [])
  end

  @spec sum(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def sum(graph) do
    enqueue(graph, "sum", [])
  end

  @spec inject(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def inject(graph, target) do
    enqueue(graph, "inject", [target])
  end

  @spec tail(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def tail(graph) do
    enqueue(graph, "tail", [1])
  end

  @spec tail(Gremlex.Graph.t(), non_neg_integer()) :: Gremlex.Graph.t()
  def tail(graph, size) do
    enqueue(graph, "tail", [size])
  end

  @spec min(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def min(graph) do
    enqueue(graph, "min", [])
  end

  @spec max(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def max(graph) do
    enqueue(graph, "max", [])
  end

  @spec identity(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def identity(graph) do
    enqueue(graph, "identity", [])
  end

  @spec constant(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def constant(graph, constant) do
    enqueue(graph, "constant", constant)
  end

  @spec id(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def id(graph) do
    enqueue(graph, "id", [])
  end

  @spec cyclic_path(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def cyclic_path(graph) do
    enqueue(graph, "cyclicPath", [])
  end

  @spec count(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def count(graph) do
    enqueue(graph, "count", [])
  end

  @spec group(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def group(graph) do
    enqueue(graph, "group", [])
  end

  @spec group_count(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def group_count(graph) do
    enqueue(graph, "groupCount", [])
  end

  @doc """
  Appends groupCount command to the traversal. Takes in a graph and the name
  of the key that will hold the aggregated grouping.
  Returns a graph to allow chainig.
  """
  @spec group_count(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def group_count(graph, key) do
    enqueue(graph, "groupCount", key)
  end

  defp enqueue(graph, op, args) when is_list(args) do
    Queue.in({op, args}, graph)
  end

  defp enqueue(graph, op, args) do
    Queue.in({op, [args]}, graph)
  end

  @doc """
  Appends values the `E` command allowing you to select an edge.
  Returns a graph to allow chaining.
  """
  @spec e(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def e(graph) do
    enqueue(graph, "E", [])
  end

  @spec e(Gremlex.Graph.t(), Gremlex.Edge.t()) :: Gremlex.Graph.t()
  def e(graph, %Gremlex.Edge{id: id}) do
    enqueue(graph, "E", [id])
  end

  @spec e(Gremlex.Graph.t(), number | String.t()) :: Gremlex.Graph.t()
  def e(graph, id) when is_number(id) or is_binary(id) do
    enqueue(graph, "E", [id])
  end

  @doc """
  Adds a namespace as property
  """
  @spec add_namespace(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def add_namespace(graph) do
    add_namespace(graph, namespace())
  end

  @spec add_namespace(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def add_namespace(graph, ns) do
    graph |> property(namespace_property(), ns)
  end

  @spec has_namespace(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def has_namespace(graph) do
    has_namespace(graph, namespace())
  end

  @spec has_namespace(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def has_namespace(graph, ns) do
    graph |> has(namespace_property(), ns)
  end

  @spec has_id(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def has_id(graph, id) do
    enqueue(graph, "hasId", id)
  end

  @spec has_key(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def has_key(graph, key) do
    enqueue(graph, "hasKey", key)
  end

  @spec has_not(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def has_not(graph, key) do
    enqueue(graph, "hasNot", key)
  end

  @spec coalesce(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def coalesce(graph, traversals) do
    enqueue(graph, "coalesce", traversals)
  end

  @spec fold(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def fold(graph) do
    enqueue(graph, "fold", [])
  end

  @spec fold(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def fold(graph, traversal) do
    enqueue(graph, "fold", [traversal])
  end

  @spec unfold(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def unfold(graph) do
    enqueue(graph, "unfold", [])
  end

  @spec as(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def as(graph, name) do
    enqueue(graph, "as", name)
  end

  @spec select(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def select(graph, names) do
    enqueue(graph, "select", names)
  end

  @spec by(Gremlex.Graph.t(), List.t() | String.t()) :: Gremlex.Graph.t()
  def by(graph, value) do
    enqueue(graph, "by", value)
  end

  @spec path(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def path(graph) do
    enqueue(graph, "path", [])
  end

  @spec simple_path(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def simple_path(graph) do
    enqueue(graph, "simplePath", [])
  end

  @spec from(Gremlex.Graph.t(), String.t()) :: Gremlex.Graph.t()
  def from(graph, name) do
    enqueue(graph, "from", [name])
  end

  @spec repeat(Gremlex.Graph.t(), Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def repeat(graph, traversal) do
    enqueue(graph, "repeat", [traversal])
  end

  @spec until(Gremlex.Graph.t(), Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def until(graph, traversal) do
    enqueue(graph, "until", [traversal])
  end

  @spec loops(Gremlex.Graph.t()) :: Gremlex.Graph.t()
  def loops(graph) do
    enqueue(graph, "loops", [])
  end

  @spec is(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def is(graph, value) do
    enqueue(graph, "is", [value])
  end

  @spec eq(Gremlex.Graph.t(), number()) :: Gremlex.Graph.t()
  def eq(graph, number) do
    enqueue(graph, "eq", [number])
  end

  @spec where(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def where(graph, traversal) do
    enqueue(graph, "where", [traversal])
  end

  @spec not_(Gremlex.Graph.t(), any()) :: Gremlex.Graph.t()
  def not_(graph, traversal) do
    enqueue(graph, "not", [traversal])
  end

  @doc """
  Creates a `within` predicate that will match at least one of the values provided.
  Takes in a range or a list as the values.
  Examples:
  ```
  g.V().has('age', within(1..18))
  g.V().has('name', within(["some", "value"]))
  ```
  """
  def within(%Range{} = range) do
    enqueue(Queue.new(), "within", [range])
  end

  def within(values) do
    enqueue(Queue.new(), "within", values)
  end

  @doc """
  Creates a `without` predicate that will filter out values that match the values provided.
  Takes in a range or a list as the values.
  Examples:
  ```
  g.V().has('age', without(18..30))
  g.V().has('name', without(["any", "value"]))
  ```
  """
  def without(%Range{} = range) do
    enqueue(Queue.new(), "without", [range])
  end

  def without(values) do
    enqueue(Queue.new(), "without", values)
  end

  @doc """
  Compiles a graph into the Gremlin query.
  """
  @spec encode(Gremlex.Graph.t()) :: String.t()
  def encode(graph) do
    encode(graph, "g")
  end

  defp encode({[], []}, acc), do: acc

  defp encode(graph, acc) do
    {{:value, {op, args}}, remainder} = :queue.out(graph)

    args =
      args
      |> Enum.map(fn
        nil ->
          "none"

        %Gremlex.Vertex{id: id} when is_number(id) ->
          "V(#{id})"

        %Gremlex.Vertex{id: id} when is_binary(id) ->
          "V('#{id}')"

        arg when is_number(arg) or is_atom(arg) ->
          "#{arg}"

        %Range{first: first, last: last} ->
          "#{first}..#{last}"

        arg when is_tuple(arg) ->
          case :queue.is_queue(arg) and :queue.get(arg) do
            {"V", _} -> encode(arg, "g")
            _ -> encode(arg, "")
          end

        str ->
          "'#{escape(str)}'"
      end)
      |> Enum.join(", ")

    construct_fn_call(acc, op, args, remainder)
  end

  @spec construct_fn_call(String.t(), String.t(), String.t(), Gremlex.Graph.t()) :: String.t()
  defp construct_fn_call("", "__", _, remainder), do: encode(remainder, "" <> "__")

  defp construct_fn_call(_, "__", _, _), do: raise("Not a valid traversal")

  defp construct_fn_call("", op, args, remainder), do: encode(remainder, "" <> "#{op}(#{args})")

  defp construct_fn_call(acc, op, args, remainder),
    do: encode(remainder, acc <> ".#{op}(#{args})")

  @spec escape(String.t()) :: String.t()
  defp escape(str) do
    # We escape single quote if it is not already escaped by an odd number of backslashes
    String.replace(str, ~r/((\A|[^\\])(\\\\)*)'/, "\\1\\'")
  end

  defp namespace_property do
    Confex.get_env(:gremlex, :namespace_property, @default_namespace_property)
  end

  defp namespace do
    Confex.get_env(:gremlex, :namespace_name, @default_namespace)
  end
end
