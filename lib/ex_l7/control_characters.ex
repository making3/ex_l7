defmodule ExL7.ControlCharacters do
  @moduledoc """
  Parses control characters for an HL7 message from the header.
  """
  defstruct segment: "\r",
            field: "|",
            component: "^",
            repeat: "~",
            escape: "\\",
            sub_component: "&"

  @doc ~S"""
  Returns the control characters for an HL7 message.

  ## Parameters

  - hl7: The HL7 message or MSH header.
  - segment_delimiter: Character that separates HL7 segments, defaults to \\r.

  ## Examples
    iex>ExL7.ControlCharacters.get_control_characters("MSH|^~\\&")
    %ExL7.ControlCharacters{segment: "\r", field: "|", component: "^", repeat: "~", escape: "\\", sub_component: "&"}
  """
  def get_control_characters(hl7, segment_delimiter \\ "\r") do
    control_character_regex =
      ~r/^MSH(?<field>.)(?<component>.)(?<repeat>.)(?<escape>.)(?<sub_component>.)/i

    control_character_regex
    |> Regex.named_captures(hl7)
    |> Map.put("segment", segment_delimiter)
    |> convert_to_struct()
  end

  defp convert_to_struct(%{} = control_characters_map) do
    %ExL7.ControlCharacters{
      segment: control_characters_map["segment"],
      field: control_characters_map["field"],
      component: control_characters_map["component"],
      repeat: control_characters_map["repeat"],
      escape: control_characters_map["escape"],
      sub_component: control_characters_map["sub_component"]
    }
  end
end
