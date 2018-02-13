defmodule ExL7.Segment do
  @moduledoc """
  Structure and Helper functions for a HL7 (ExL7.Message) segment.
  """

  defstruct fields: []
  alias ExL7.Field
  alias ExL7.Segment

  @doc ~S"""
  Returns an ExL7.Segment from a given list of strings.

  ## Parameters

  - segment_string: String that represents an HL7 segment.
  - control_characters: ExL7.ControlCharacters used to parse fields, components, and sub components.
  """
  def parse(segment_string, control_characters) do
    %Segment{fields: do_parse(segment_string, control_characters)}
  end

  defp do_parse(segment_string, control_characters) do
    segment_string
    |> String.split(control_characters.field)
    |> Enum.map(&String.split(&1, control_characters.repeat))
    |> Enum.map(&parse_fields(&1, control_characters))
  end

  defp parse_fields(fields, control_characters) do
    case length(fields) do
      1 -> Field.parse(Enum.at(fields, 0), control_characters)
      _ -> Enum.map(fields, &Field.parse(&1, control_characters))
    end
  end

  @doc ~S"""
  Returns the ID of the segment, such as MSH, PID, and PV1.

  ## Parameters

  - segment: An ExL7.Segment.
  """
  def get_id(segment) do
    # No need to pass in control_characters since the first field
    #   should be upper case 3 letters.
    segment.fields
    |> Enum.at(0)
    |> Field.to_string(%ExL7.ControlCharacters{})
  end

  @doc ~S"""
  Returns a HL7 segment string from a single ExL7.Segment.

  ## Parameters

  - segment: An ExL7.Segment.
  - control_characters: ExL7.ControlCharacters used to join fields, components, and sub components.
  """
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
