defmodule ExL7 do
  @moduledoc """
  HL7 parsing and querying application
  """

  @doc ~S"""
  Parses an HL7 message into an ExL7.Message for ExL7 usage. Validates first.
    For validation examples, check ExL7.Validation.validate.

    ## Parameters

    - hl7: HL7 message to parse.
    - segment_delimiter: An alternative value other than \\r to split message segments.
  """
  def parse(hl7, segment_delimiter \\ "\r") do
    ExL7.Parser.parse(hl7, segment_delimiter)
  end

  @doc ~S"""
  Checks if an HL7 message is valid.

  ## Parameters

  - hl7: HL7 message to validate.
  - segment_delimiter: An alternative value other than \\r to split message segments.

  ## Examples

      iex> ExL7.validate("")
      {:error, "No Data"}

      iex> ExL7.validate("MSH|")
      {:error, "Invalid Header"}

      iex> ExL7.validate("MSH|")
      {:error, "Invalid Header"}

      iex> ExL7.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4")
      {:error, "No Segments Found"}

      iex> ExL7.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPI\rPIDD")
      {:error, "Invalid Segment(s)"}

      iex> ExL7.validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID\rXFA")
      {:ok, nil}

  """
  def validate(hl7, segment_delimiter \\ "\r") do
    ExL7.Validation.validate(hl7, segment_delimiter)
  end
end
