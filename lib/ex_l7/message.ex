defmodule ExL7.Message do
  @moduledoc """
  Documentation for ExL7.Message
  """
  alias ExL7.QueryParser
  alias ExL7.Segment

  defstruct segments: [], timezone: "UTC", control_characters: %ExL7.ControlCharacters{}

  def query(query_string, date_time_format) do
    # TODO: Implementation
    {:ok, query} = QueryParser.parse(query_string)
  end

  def to_string(message) do
    hl7 =
      message.segments
      |> Enum.map(&Segment.to_string(&1, message.control_characters))
      |> Enum.join(message.control_characters.segment)

    # Messages always end with a segment control character, usually a line feed ending
    hl7 <> message.control_characters.segment
  end
end
