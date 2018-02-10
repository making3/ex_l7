defmodule ExL7.Parser do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  import ExL7.Validation
  alias ExL7.Message
  alias ExL7.Segment
  alias ExL7.Trimmer
  alias ExL7.ControlCharacters

  def parse(hl7, segment_delimiter \\ "\r", timezone \\ "UTC") do
    case validate(hl7, segment_delimiter) do
      {:ok, _} ->
        do_parse(hl7, segment_delimiter, timezone)

      error_result = {:error, _} ->
        error_result
    end
  end

  defp do_parse(hl7, segment_delimiter, timezone) do
    control_characters = ControlCharacters.get_control_characters(hl7, segment_delimiter)

    {:ok,
     %Message{
       segments: get_segments(hl7, segment_delimiter, control_characters),
       control_characters: control_characters,
       timezone: timezone
     }}
  end

  defp get_segments(hl7, segment_delimiter, control_characters) do
    hl7
    |> String.split(segment_delimiter)
    |> Enum.map(&Trimmer.trim_segment/1)
    |> Enum.map(&Segment.parse(&1, control_characters))
  end

  def parse_file(file_with_hl7, segment_delimiter \\ "\r", timezone \\ "UTC") do
    case read_file(file_with_hl7) do
      {:ok, hl7} -> parse(hl7, segment_delimiter, timezone)
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
