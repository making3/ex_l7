defmodule ExL7.Parser do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  import ExL7.Validation
  alias ExL7.Message
  alias ExL7.Segment
  alias ExL7.Trimmer
  alias ExL7.ControlCharacters

  def parse(hl7_string, segment_delimiter \\ "\r", timezone \\ "UTC") do
    # TODO: Cleanup a bit
    validate(hl7_string, segment_delimiter)
    |> do_parse(hl7_string, segment_delimiter, timezone)
  end

  defp do_parse(err_result = {:error, _}, _hl7, _segment_delimiter, _timezone) do
    err_result
  end

  defp do_parse({:ok, _}, hl7, segment_delimiter, timezone) do
    control_characters = ControlCharacters.get_control_characters(hl7, segment_delimiter)

    segments =
      hl7
      |> String.split(segment_delimiter)
      |> Enum.map(&Trimmer.trim_segment/1)
      |> Enum.map(&Segment.parse(&1, control_characters))

    {:ok,
     %Message{
       segments: segments,
       control_characters: control_characters,
       timezone: timezone
     }}
  end

  def parse_file(file_with_hl7, segment_delimiter \\ "\r", timezone \\ "UTC") do
    file_with_hl7
    |> File.exists?()
    |> read_file(file_with_hl7, segment_delimiter, timezone)
  end

  defp read_file(false, _file_name, _segment_delimiter, _timezone) do
    {:error, "Invalid File"}
  end

  defp read_file(true, file_name, segment_delimiter, timezone) do
    {:ok, file} = File.open(file_name, [:read])

    case IO.read(file, :all) do
      :eof -> {:error, "No Data"}
      hl7 -> parse(hl7, segment_delimiter, timezone)
    end
  end
end
