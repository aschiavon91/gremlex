defmodule Gremlex.Request do
  alias Gremlex.Graph
  @derive Jason.Encoder
  @op "eval"
  @processor ""
  @enforce_keys [:op, :processor, :requestId, :args]
  defstruct [:op, :processor, :requestId, :args]

  @doc """
  Accepts plain query or a graph and returns a Request.
  """
  @spec new(String.t()) :: Request
  def new(query) when is_binary(query) do
    args = %{gremlin: query, language: "gremlin-groovy"}
    %Gremlex.Request{requestId: UUID.uuid4(), args: args, op: @op, processor: @processor}
  end

  @spec new(Gremlex.Graph.t()) :: Request
  def new(query) do
    new(Graph.encode(query))
  end
end
