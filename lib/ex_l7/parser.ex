defmodule ExL7.Parser do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  import ExL7.Validation

  def parse(hl7_string) do
    validate(hl7_string)

    # TODO: Implementation
  end

  def parse_file(file_with_hl7) do
    file_with_hl7
    |> File.exists?()
    |> read_file(file_with_hl7)

    # TODO: Implementation
  end

  defp read_file(false, _file_name) do
    {:error, "Invalid File"}
  end

  defp read_file(true, file_name) do
    {:ok, file} = File.open(file_name, [:read])

    case IO.read(file, :all) do
      :eof -> {:error, "No Data"}
      hl7 -> parse(hl7)
    end
  end
end
