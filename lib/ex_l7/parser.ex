defmodule ExL7.Parser do
  @moduledoc """
  Parses an HL7 message and returns an ExL7.Message that can be ran under
    ExL7.Query to return data, ExL7.Ack to generate an acknowledgement for the
    message, or ExL7.Transform to modify the message.
  """

  import ExL7.Validation
  alias ExL7.Message
  alias ExL7.Segment
  alias ExL7.Trimmer
  alias ExL7.ControlCharacters

  @doc ~S"""
  Parses an HL7 message into an ExL7.Message for ExL7 usage. Validates first.
    For validation examples, check ExL7.Validation.validate.

    ## Parameters

    - hl7: The HL7 message to parse.
    - segment_delimiter: An alternative value other than \\r to split message segments.
  """
  def parse(hl7, segment_delimiter \\ "\r") do
    case validate(hl7, segment_delimiter) do
      {:ok, _} ->
        do_parse(hl7, segment_delimiter)

      error_result = {:error, _} ->
        error_result
    end
  end

  defp do_parse(hl7, segment_delimiter) do
    control_characters = ControlCharacters.get_control_characters(hl7, segment_delimiter)

    {:ok,
     %Message{
       segments: get_segments(hl7, segment_delimiter, control_characters),
       control_characters: control_characters
     }}
  end

  defp get_segments(hl7, segment_delimiter, control_characters) do
    hl7
    |> String.split(segment_delimiter)
    |> Enum.map(&Trimmer.trim_segment/1)
    |> Enum.map(&Segment.parse(&1, control_characters))
  end

  def parse_file(file_with_hl7, segment_delimiter \\ "\r") do
    case read_file(file_with_hl7) do
      {:ok, hl7} -> parse(hl7, segment_delimiter)
      error -> error
    end
  end

  defp read_file(file_name) do
    with true <- File.exists?(file_name),
         {:ok, file} <- File.open(file_name, [:read]),
         hl7 <- IO.read(file, :all) do
      {:ok, hl7}
    else
      false -> {:error, "Invalid File"}
      :eof -> {:error, "No Data"}
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end
end
