defmodule ExL7.Component do
  # TODO: Docs & Tests

  def to_string(components, control_characters) when is_list(components) do
    Enum.join(components, control_characters.sub_component)
  end

  def to_string(component, _control_characters) do
    component
  end
end
