defmodule ExL7.Validation do
  @moduledoc """
  Documentation for ExL7.Validation
  """

  @doc """
  Validates an HL7

  ## Examples

      iex> ExL7.Validation.validate("M")
      {:error, "Invalid Header"}

  """

  alias ExL7.Trimmer

  def validate(hl7, segment_delimiter \\ "\r")

  def validate("", _segment_delimiter) do
    {:error, "No Data"}
  end

  def validate(hl7, segment_delimiter) when is_binary(hl7) do
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
    {:ok, nil}
  end

  defp validate_segment(segment_regex, [segment | remaining_segments]) do
    trimmed_segment = Trimmer.trim_segment(segment)

    case trimmed_segment == "" or Regex.match?(segment_regex, trimmed_segment) do
      true ->
        validate_segment(segment_regex, remaining_segments)

      _ ->
        {:error, "Invalid Segment(s)"}
    end
  end
end
