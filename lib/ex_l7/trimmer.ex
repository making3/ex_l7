defmodule ExL7.Trimmer do
  @moduledoc """
  String trimming helper functions specific for HL7 messages
  """

  @doc ~S"""
  Trim's a HL7 message segment from line endings, null characters, and tabs.
  """
  def trim_segment(segment) do
    segment = Regex.replace(~r/[\r\n\0\t]+$/, segment, "")
    Regex.replace(~r/^[\r\n\0\t]*/, segment, "")
  end
end
