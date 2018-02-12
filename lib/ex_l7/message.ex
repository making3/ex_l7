defmodule ExL7.Message do
  @moduledoc """
  Structure and Helper functions for a ExL7 parsed HL7 message
  """

  alias ExL7.Segment

  defstruct segments: [], control_characters: %ExL7.ControlCharacters{}

  @doc ~S"""

  ## Parameters
  Returns an HL7 message from an ExL7.Message.

  - message: ExL7 message to dump as a string
  """
  def to_string(message) do
    hl7 =
      message.segments
      |> Enum.map(&Segment.to_string(&1, message.control_characters))
      |> Enum.join(message.control_characters.segment)

    # Messages always end with a segment control character, usually a line feed ending
    hl7 <> message.control_characters.segment
  end
end
