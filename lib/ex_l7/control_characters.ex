defmodule ExL7.ControlCharacters do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  def get_control_characters(hl7, segment_delimiter \\ "\r") do
    control_character_regex =
      ~r/^MSH(?<field>.)(?<component>.)(?<repeat>.)(?<escape>.)(?<sub_component>.)/i

    control_character_regex
    |> Regex.named_captures(hl7)
    |> Map.put("segment", segment_delimiter)
    |> convert_keys_to_atoms()
  end

  defp convert_keys_to_atoms(map) do
    # Credit: https://stackoverflow.com/a/31990445/724591
    for {key, val} <- map,
        into: %{},
        do: {String.to_atom(key), val}
  end
end
