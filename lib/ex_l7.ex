defmodule ExL7 do
  @moduledoc """
  Lightweight HL7 parsing, validation, querying, and transformation library.
  """

  alias ExL7.Message
  alias ExL7.Query.DateOptions

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

  @doc """
  Returns a value from an ExL7.Message using a ExL7 query string

  ## Parameters

  - message: An ExL7.Message map.
  - query_string: ExL7 query string for retrieving a value.
  - date_options: ExL7.Query.DateOptions struct.

  """
  def query(%Message{} = message, query_string, %DateOptions{} = date_options \\ %DateOptions{}) do
    ExL7.Query.query(message, query_string, date_options)
  end
end
