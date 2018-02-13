defmodule ExL7.QueryParser do
  @moduledoc """
  Helper functions to parse ExL7.Query strings.
  """

  alias ExL7.Query

  @doc """
  Parses an l7_query query

  ## Parameters

  - l7_query: String query to find a value in an HL7 message.

  ## Examples

      iex> ExL7.QueryParser.parse("")
      {:error, "Invalid Query"}

  """
  def parse(l7_query) do
    ~r/^(?<date>@{0,2})(?<segment>\w{3})\|(?<field>\d+)(?:\^(?<component>\d+)(?:&(?<sub_component>\d+))?(?:\[(?<repeat>\d+)\])?)?$/
    |> Regex.named_captures(l7_query)
    |> return_normal(l7_query)
  end

  defp return_normal(nil, l7_query) do
    try_parse_multi_segment(l7_query)
  end

  defp return_normal(matches, _) do
    query =
      %Query{all_segments: false}
      |> fetch_date(matches)
      |> fetch_segment(matches["segment"])
      |> fetch_field(matches["field"])
      |> fetch_component(matches["component"])
      |> fetch_sub_component(matches["sub_component"])
      |> fetch_repeat(matches["repeat"])

    {:ok, query}
  end

  defp try_parse_multi_segment(l7_query) do
    ~r/^(?<date>@{0,2})(?<segment>\w{3})(?:\[(?<field>\d+)\]|\|(?<component_field>\d+)(?:\[(?<component>\d+)\]))$/i
    |> Regex.named_captures(l7_query)
    |> return_multi_segment(l7_query)
  end

  defp return_multi_segment(nil, l7_query) do
    try_parse_component_match(l7_query)
  end

  defp return_multi_segment(matches, _l7_query) do
    field = if matches["field"] == "", do: matches["component_field"], else: matches["field"]

    query =
      %Query{all_segments: true}
      |> fetch_date(matches)
      |> fetch_segment(matches["segment"])
      |> fetch_field(field)
      |> fetch_component(matches["component"])

    {:ok, query}
  end

  defp try_parse_component_match(l7_query) do
    ~r/^(?<date>@{0,2})(?<segment>\w{3})\|(?<field>\d+)\((?<component_match>\d+),(?<component_match_value>[\w|\s]+)\)(?:\^(?<component>\d+))?(?:&(?<sub_component>\d+))?$/i
    |> Regex.named_captures(l7_query)
    |> return_component_match()
  end

  defp return_component_match(nil) do
    {:error, "Invalid Query"}
  end

  defp return_component_match(matches) do
    query =
      %Query{all_segments: false}
      |> fetch_date(matches)
      |> fetch_segment(matches["segment"])
      |> fetch_field(matches["field"])
      |> fetch_component_match(matches["component_match"], matches["component_match_value"])
      |> fetch_component(matches["component"])
      |> fetch_sub_component(matches["sub_component"])

    {:ok, query}
  end

  defp fetch_date(query, matches) do
    query = %{query | is_date: is_date_query(matches["date"])}
    %{query | default_time: is_default_time(matches["date"])}
  end

  defp is_date_query(match), do: match == "@" or match == "@@"
  defp is_default_time(match), do: match == "@@"

  defp fetch_segment(query, segment) do
    %{query | segment: segment}
  end

  defp fetch_field(query, field) do
    %{query | field: String.to_integer(field)}
  end

  defp fetch_component(query, "") do
    query
  end

  defp fetch_component(query, component) do
    %{query | component: String.to_integer(component)}
  end

  defp fetch_repeat(query, "") do
    query
  end

  defp fetch_repeat(query, repeat) do
    %{query | repeat: String.to_integer(repeat)}
  end

  defp fetch_component_match(query, component, value) do
    component_match = %{
      query.component_match
      | component: String.to_integer(component),
        value: value
    }

    %{query | component_match: component_match}
  end

  defp fetch_sub_component(query, "") do
    query
  end

  defp fetch_sub_component(query, sub_component) do
    %{query | sub_component: String.to_integer(sub_component)}
  end
end
