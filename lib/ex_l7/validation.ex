defmodule ExL7.Validation do
  @moduledoc """
  Module to check if HL7 messages are valid.
  """

  alias ExL7.Trimmer

  @doc ~S"""
  Checks if an HL7 message is valid.

  ## Parameters

  - hl7: HL7 message to validate.
  - segment_delimiter: An alternative value other than \\r to split message segments.

  ## Examples

      iex> ExL7.Validation.validate("")
      {:error, "No Data"}

      iex> ExL7.Validation.validate("MSH|")
      {:error, "Invalid Header"}

      iex> ExL7.Validation.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4")
      {:error, "No Segments Found"}

      iex> ExL7.Validation.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPI\rPIDD")
      {:error, "Invalid Segment(s)"}

      iex> ExL7.Validation.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID\rXFA")
      {:ok, nil}

  """
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
    # TODO: Should something specific be returned? Segments maybe?
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
