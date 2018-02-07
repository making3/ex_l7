defmodule ExL7.Parser do
  @moduledoc """
  Documentation for ExL7.QueryParser
  """

  def parse(hl7_string) do
    # TODO: Implementation
  end

  def parse_file(file_with_hl7) do
    # TODO: Implementation
  end

  @doc """
  Validates an HL7

  ## Examples

      iex> ExL7.Parser.validate("M")
      {:error, "Invalid Header"}

  """
  def validate(hl7, segment_delimiter \\ "\r") when is_binary(hl7) do
    validate_header(hl7, segment_delimiter)
  end

  defp validate_header(hl7, segment_delimiter) do
    header_match = Regex.named_captures(~r/^MSH(?<field>.).{4}\1.*$/im, hl7)
    is_header_valid(hl7, segment_delimiter, header_match)
  end

  defp is_header_valid(_hl7, _segment_delimiter, nil) do
    {:error, "Invalid Header"}
  end

  defp is_header_valid(hl7, segment_delimiter, captures) do
    segment_regex = Regex.compile!("^\\w{3}($|\\" <> captures["field"] <> ".*$)")
    [_msh | segments] = String.split(hl7, segment_delimiter)
    validate_contains_segments(segment_regex, segments)
  end

  defp validate_contains_segments(_, []) do
    {:error, "No Segments Found"}
  end

  defp validate_contains_segments(segment_regex, segments) do
    validate_segment(segment_regex, segments)
  end

  defp validate_segment(_, []) do
    {:ok, %ExL7.Message{}}
  end

  defp validate_segment(segment_regex, [segment | remaining_segments]) do
    case Regex.match?(segment_regex, segment) do
      true ->
        validate_segment(segment_regex, remaining_segments)

      _ ->
        {:error, "Invalid Segment(s)"}
    end
  end
end
