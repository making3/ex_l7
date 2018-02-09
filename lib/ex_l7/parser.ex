defmodule ExL7.Parser do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  import ExL7.Validation

  def parse(hl7_string, segment_delimiter \\ "\r") do
    validate(hl7_string)
    |> do_parse(hl7_string, segment_delimiter)
  end

  defp do_parse(err_result = {:error, _}, _hl7, _segment_delimiter) do
    err_result
  end

  defp do_parse({:ok, _}, hl7, segment_delimiter) do
    String.split(hl7, segment_delimiter)
  end

  def parse_file(file_with_hl7, segment_delimiter \\ "\r") do
    file_with_hl7
    |> File.exists?()
    |> read_file(file_with_hl7, segment_delimiter)
  end

  defp read_file(false, _file_name, _segment_delimiter) do
    {:error, "Invalid File"}
  end

  defp read_file(true, file_name, segment_delimiter) do
    {:ok, file} = File.open(file_name, [:read])

    case IO.read(file, :all) do
      :eof -> {:error, "No Data"}
      hl7 -> parse(hl7, segment_delimiter)
    end
  end
end
