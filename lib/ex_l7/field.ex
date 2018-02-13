defmodule ExL7.Field do
  @moduledoc """
  Structure and Helper functions for a HL7 (ExL7.Message) field.
  """

  alias ExL7.Field

  defstruct components: []

  @doc ~S"""
  Returns an ExL7.Field from a given list of strings.

  ## Parameters

  - field_strings: String or list of strings that represent an HL7 field.
  - control_characters: ExL7.ControlCharacters used to parse components and sub components.
  """
  def parse(field_strings, control_characters) when is_list(field_strings) do
    Enum.map(field_strings, &parse(&1, control_characters))
  end

  def parse(field_string, control_characters) do
    %Field{components: do_parse(field_string, control_characters)}
  end

  defp do_parse(field_string, control_characters) do
    field_string
    |> String.split(control_characters.component)
    |> Enum.map(&parse_sub_components(&1, control_characters))
  end

  defp parse_sub_components(component, control_characters) do
    sub_components = String.split(component, control_characters.sub_component)

    case length(sub_components) do
      1 -> Enum.at(sub_components, 0)
      _ -> sub_components
    end
  end

  @doc ~S"""
  Returns one or many HL7 field strings representation from one or many ExL7.Fields.

  ## Parameters

  - fields: One or many ExL7.Field maps.
  - control_characters: ExL7.ControlCharacters used to join fields, components, and sub components.
  """
  def to_string(fields, control_characters) when is_list(fields) do
    fields
    |> Enum.map(&to_string(&1, control_characters))
  end

  def to_string(field, control_characters) do
    field.components
    |> Enum.map(&join_sub_components(&1, control_characters))
    |> Enum.join(control_characters.component)
  end

  defp join_sub_components(sub_components, control_characters) when is_list(sub_components) do
    Enum.join(sub_components, control_characters.sub_component)
  end

  defp join_sub_components(sub_component, _control_characters) do
    sub_component
  end

  def get_value(field, control_characters, query) do
    get_component(field.components, query.component)
    |> get_sub_component(control_characters, query.sub_component)
  end

  defp get_component(components, position) when is_list(components) do
    Enum.at(components, position)
  end

  defp get_sub_component(component, control_characters, position) when position == -1 do
    join_sub_components(component, control_characters)
  end

  defp get_sub_component(component, _control_characters, position) when is_list(component) do
    Enum.at(component, position)
  end

  defp get_sub_component(_component, _control_characters, position) when position > 0 do
    nil
  end

  defp get_sub_component(component, _control_characters, _position) do
    component
  end
end
