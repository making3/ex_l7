defmodule ExL7.Query do
  @moduledoc """
  Documentation for ExL7.Query
  """
  alias ExL7.Segment
  alias ExL7.Field
  alias ExL7.QueryParser

  defstruct all_segments: false,
            segment: "",
            repeat: -1,
            field: 0,
            component: -1,
            component_match: %ExL7.Query.ComponentMatch{},
            sub_component: -1,
            is_date: false,
            default_time: false

  def query(message, query_string, _date_time_format \\ "TODO") do
    IO.inspect(query_string, label: "qs")
    {:ok, query} = QueryParser.parse(query_string)
    IO.inspect(query, label: "query")
    query_segment(message, query)
  end

  defp query_segment(message, query) do
    segments = match_segment(message.segments, query.segment)

    cond do
      segments == nil or length(segments) == 0 -> ""
      length(segments) > 1 -> Enum.map(segments, &query_field(message, &1, query))
      true -> query_field(message, Enum.at(segments, 0), query)
    end
  end

  defp match_segment(segments, query_segment) do
    Enum.filter(segments, fn segment ->
      Segment.get_id(segment) == query_segment
    end)
  end

  defp query_field(message, segment, query) do
    IO.inspect(segment.fields, label: "fields")

    case Enum.at(segment.fields, query.field) do
      nil -> ""
      field -> query_component(message, field, query)
    end
  end

  # defp query_component(message, field, query = %{all_segments: true, component: -1}) do
  #   field
  # end

  defp query_component(message, field, query) do
    IO.inspect(field, label: "comp")

    if query.component < 0 do
      Field.to_string(field, message.control_characters)
    else
      find_component(message, field, query)
    end
  end

  defp find_component(message, fields, query) when is_list(fields) do
    components = Enum.map(fields, &find_component(message, &1, query))

    if query.repeat < 0 do
      components
    else
      Enum.at(components, query.repeat)
    end
  end

  defp find_component(message, field, query) do
    case Enum.at(field.components, query.component) do
      nil -> Field.to_string(field, message.control_characters)
      component -> component
    end
  end
end
