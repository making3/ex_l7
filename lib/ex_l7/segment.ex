defmodule ExL7.Segment do
  @moduledoc """
  Documentation for ExL7.Segment
  """
  defstruct fields: []
  alias ExL7.Field

  def get_id(segment) do
    # No need to pass in control_characters since the first field
    #   should be upper case 3 letters.
    segment.fields
    |> Enum.at(0)
    |> Field.to_string(%ExL7.ControlCharacters{})
  end

  def to_string(segment, control_characters) do
    segment.fields
    |> Enum.map(&get_field_string(&1, control_characters))
    |> Enum.join(control_characters.field)
  end

  defp get_field_string(fields, control_characters) when is_list(fields) do
    fields
    |> Enum.map(&Field.to_string(&1, control_characters))
    |> Enum.join(control_characters.repeat)
  end

  defp get_field_string(field, control_characters) do
    Field.to_string(field, control_characters)
  end
end
