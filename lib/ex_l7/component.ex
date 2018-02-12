defmodule ExL7.Component do
  @moduledoc """
  Helper functions for components
  """

  @doc ~S"""
  Returns a string with sub components joined together, if any.

  ## Parameters

  - components: A string or string list of components.
  - control_characters: ExL7.ControlCharacters used to join components

  ## Examples

      iex> ExL7.Component.to_string("foo", %ExL7.ControlCharacters{})
      "foo"

      iex> ExL7.Component.to_string(["blue", "orange"], %ExL7.ControlCharacters{})
      "blue&orange"
  """
  def to_string(components, control_characters) when is_list(components) do
    Enum.join(components, control_characters.sub_component)
  end

  def to_string(component, _control_characters) do
    component
  end
end
