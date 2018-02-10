defmodule ExL7.Trimmer do
  @moduledoc """
  Documentation for ExL7.Trimmer
  """

  def trim_segment(segment) do
    segment = Regex.replace(~r/[\r\n\0\t]+$/, segment, "")
    Regex.replace(~r/^[\r\n\0\t]*/, segment, "")
  end
end
