defmodule ExL7.ControlCharacters do
  @moduledoc """
  Documentation for ExL7.Parser
  """
  defstruct segment: "\r",
            field: "|",
            component: "^",
            repeat: "~",
            escape: "\\",
            sub_component: "&"

  def get_control_characters(hl7, segment_delimiter \\ "\r") do
    control_character_regex =
      ~r/^MSH(?<field>.)(?<component>.)(?<repeat>.)(?<escape>.)(?<sub_component>.)/i

    control_character_regex
    |> Regex.named_captures(hl7)
    |> Map.put("segment", segment_delimiter)
    |> convert_to_struct()
  end

  defp convert_to_struct(control_characters) do
    %ExL7.ControlCharacters{
      segment: control_characters["segment"],
      field: control_characters["field"],
      component: control_characters["component"],
      repeat: control_characters["repeat"],
      escape: control_characters["escape"],
      sub_component: control_characters["sub_component"]
    }
  end
end
