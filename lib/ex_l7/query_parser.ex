defmodule ExL7.QueryParser do
  @moduledoc """
  Documentation for ExL7.QueryParser
  """

  @doc """
  Parses an hl7 query

  ## Examples

      iex> ExL7.QueryParser.parse("")
      {:error, "Invalid query"}

  """
  def parse("") do
    {:error, "Invalid query"}
  end
  def parse(query) do
    query
  end
end
