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
    # TODO: Implementation
  end
end
