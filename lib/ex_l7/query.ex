defmodule ExL7.Query do
  @moduledoc """
  ExL7.Message querying functions and structure.
  """

  alias ExL7.Message
  alias ExL7.Segment
  alias ExL7.Field
  alias ExL7.Component
  alias ExL7.Query
  alias ExL7.QueryParser
  alias ExL7.Query.DateOptions

  defstruct all_segments: false,
            segment: "",
            repeat: -1,
            field: 0,
            component: -1,
            component_match: %Query.ComponentMatch{},
            sub_component: -1,
            is_date: false

  @doc """
  Returns a value from an ExL7.Message using a ExL7 query string

  ## Parameters

  - message: An ExL7.Message map.
  - query_string: ExL7 query string for retrieving a value.
  - date_options: ExL7.Query.DateOptions struct.

  """
  def query(%Message{} = message, query_string, %DateOptions{} = date_options \\ %DateOptions{}) do
    {:ok, query} = QueryParser.parse(query_string)
    value = find_segment(message, query)

    if query.is_date do
      format_datetime(value, date_options)
    else
      value
    end
  end

  defp format_datetime(value, %DateOptions{ignore_timezone: true} = date_options) do
    value
    |> ExL7.Date.convert("")
    |> ExL7.Date.format(date_options.format)
  end

  defp format_datetime(value, %DateOptions{} = date_options) do
    value
    |> ExL7.Date.convert(date_options.timezone)
    |> ExL7.Date.format(date_options.format)
  end

  defp find_segment(%Message{} = message, %ExL7.Query{} = query) do
    segments = match_segment(message.segments, query.segment)

    cond do
      segments == nil or length(segments) == 0 -> ""
      length(segments) > 1 -> Enum.map(segments, &find_field(message, &1, query))
      true -> find_field(message, Enum.at(segments, 0), query)
    end
  end

  defp match_segment(segments, query_segment) do
    Enum.filter(segments, fn segment ->
      Segment.get_id(segment) == query_segment
    end)
  end

  defp find_field(%Message{} = message, %Segment{} = segment, %ExL7.Query{} = query) do
    case Enum.at(segment.fields, query.field) do
      nil ->
        ""

      field ->
        cond do
          query.component_match.component > -1 ->
            matched_field = match_field(field, query.component_match)
            find_matched_field(message, matched_field, query)

          true ->
            find_matched_field(message, field, query)
        end
    end
  end

  defp match_field(fields, component_match) when is_list(fields) do
    Enum.find(fields, &match_component(&1, component_match))
  end

  defp match_field(field, component_match) do
    if match_component(field, component_match) do
      field
    end
  end

  def match_component(field, component_match) do
    Enum.at(field.components, component_match.component) == component_match.value
  end

  defp find_matched_field(message, field, query) do
    cond do
      field == nil ->
        ""

      query.component < 0 ->
        Field.to_string(field, message.control_characters)

      true ->
        find_component(message, field, query)
    end
  end

  defp find_component(%Message{} = message, fields, %ExL7.Query{} = query) when is_list(fields) do
    components = Enum.map(fields, &find_component(message, &1, query))

    if query.repeat < 0 do
      components
    else
      Enum.at(components, query.repeat)
    end
  end

  defp find_component(%Message{} = message, %Field{} = field, %ExL7.Query{} = query) do
    case Enum.at(field.components, query.component) do
      nil -> Field.to_string(field, message.control_characters)
      component -> find_sub_component(message, component, query)
    end
  end

  defp find_sub_component(%Message{} = message, component, %ExL7.Query{} = query) do
    if query.sub_component < 0 do
      Component.to_string(component, message.control_characters)
    else
      Enum.at(component, query.sub_component)
    end
  end
end
