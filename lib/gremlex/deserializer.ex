defmodule Gremlex.Deserializer do
  @moduledoc """
  Deserializer module for deserializing data returned back from Gremlin.
  """
  alias Gremlex.{Edge, Vertex, VertexProperty}

  def deserialize(%{"result" => result}) do
    case result["data"] do
      nil ->
        nil

      %{"@type" => type, "@value" => value} ->
        deserialize(type, value)
    end
  end

  def deserialize(%{"@type" => type, "@value" => value}) do
    deserialize(type, value)
  end

  def deserialize(val), do: val

  def deserialize("g:List", value) do
    Enum.map(value, fn
      %{"@type" => type, "@value" => value} ->
        deserialize(type, value)

      value ->
        value
    end)
  end

  def deserialize("g:Set", value) do
    value
    |> Enum.map(fn
      %{"@type" => type, "@value" => value} ->
        deserialize(type, value)

      value ->
        value
    end)
    |> MapSet.new()
  end

  def deserialize("g:Map", value) do
    value
    |> Enum.chunk_every(2)
    |> Enum.map(fn [key, value] ->
      key = deserialize(key)
      value = deserialize(value)
      {key, value}
    end)
    |> Map.new()
  end

  def deserialize("g:Vertex", value) do
    Vertex.from_response(value)
  end

  def deserialize("g:VertexProperty", value) do
    VertexProperty.from_response(value)
  end

  def deserialize("g:Edge", value) do
    Edge.from_response(value)
  end

  def deserialize("g:Int64", value) when is_number(value), do: value

  def deserialize("g:Int32", value) when is_number(value), do: value

  def deserialize("g:Double", value) when is_number(value), do: value

  def deserialize("g:Float", value) when is_number(value), do: value

  def deserialize("g:UUID", value), do: value

  def deserialize("g:T", value), do: value

  def deserialize("g:Date", value) do
    DateTime.from_unix!(value, :microsecond)
  end

  def deserialize("g:Timestamp", value) do
    DateTime.from_unix!(value, :microsecond)
  end

  def deserialize(_type, value), do: value
end
