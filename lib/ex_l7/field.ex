defmodule ExL7.Field do
  @moduledoc """
  Documentation for ExL7.Parser
  """

  defstruct components: []

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
