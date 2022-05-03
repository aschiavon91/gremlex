defmodule Gremlex.Edge do
  alias Gremlex.Deserializer
  @enforce_keys [:label, :id, :in_vertex, :out_vertex, :properties]
  @derive Jason.Encoder
  @type t :: %Gremlex.Edge{
          label: String.t(),
          id: number(),
          properties: map(),
          in_vertex: Gremlex.Vertex.t(),
          out_vertex: Gremlex.Vertex.t()
        }
  defstruct [:label, :id, :in_vertex, :out_vertex, :properties]

  def new(
        id,
        label,
        in_vertex_id,
        in_vertex_label,
        out_vertex_id,
        out_vertex_label,
        properties \\ %{}
      ) do
    in_vertex = %Gremlex.Vertex{id: in_vertex_id, label: in_vertex_label}
    out_vertex = %Gremlex.Vertex{id: out_vertex_id, label: out_vertex_label}

    %Gremlex.Edge{
      id: id,
      label: label,
      in_vertex: in_vertex,
      out_vertex: out_vertex,
      properties: properties
    }
  end

  def from_response(value) do
    %{
      "id" => edge_id,
      "inV" => in_v,
      "inVLabel" => in_v_label,
      "label" => label,
      "outV" => out_v,
      "outVLabel" => out_v_label
    } = value

    json_properties = Map.get(value, "properties", %{})
    id = Deserializer.deserialize(edge_id)
    in_v_id = Deserializer.deserialize(in_v)
    out_v_id = Deserializer.deserialize(out_v)

    properties =
      Enum.reduce(json_properties, %{}, fn {key, prop_value}, acc ->
        %{"@type" => type, "@value" => value} = prop_value
        value = Deserializer.deserialize(type, value)
        Map.put(acc, String.to_atom(key), value)
      end)

    Gremlex.Edge.new(
      id,
      label,
      in_v_id,
      in_v_label,
      out_v_id,
      out_v_label,
      properties
    )
  end
end
