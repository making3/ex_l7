defmodule ExL7.Date do
  @moduledoc """
  Helper functions for HL7 date times
  """
  @input_formats [
    "{YYYY}{0M}{0D}",
    "{YYYY}{0M}{0D}{h24}",
    "{YYYY}{0M}{0D}{h24}ZZ",
    "{YYYY}{0M}{0D}{h24}{m}",
    "{YYYY}{0M}{0D}{h24}{m}ZZ",
    "{YYYY}{0M}{0D}{h24}{m}{s}",
    "{YYYY}{0M}{0D}{h24}{m}{s}{Z}",
    "{YYYY}{0M}{0D}{h24}{m}{s}{ss}{Z}"
  ]

  @doc """
  Converts an HL7 specified date to a recognizable date format

  ## Parameters

  - date_time: HL7 string that represents a date time
  - output_format: Timex string format to represent a date time format.
  """
  def convert(date_time, timezone) do
    cond do
      String.length(date_time) == 8 ->
        convert(date_time, timezone, "{YYYY}-{0M}-{0D}")

      true ->
        convert(date_time, timezone, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
    end
  end

  def convert(date_time, timezone, output_format) do
    try_convert(date_time, timezone, output_format, @input_formats)
  end

  defp try_convert(date_time, _, _, []) do
    date_time
  end

  defp try_convert(date_time, timezone, output_format, [input_format | input_formats]) do
    case Timex.parse(date_time, input_format) do
      {:ok, formatted_date_time} ->
        to_normalized_format(formatted_date_time, timezone, output_format)

      {:error, _} ->
        try_convert(date_time, timezone, output_format, input_formats)
    end
  end

  defp to_normalized_format(%DateTime{} = date_time, _, output_format) do
    date_time
    |> Timex.Timezone.convert("UTC")
    |> Timex.format!(output_format)
  end

  defp to_normalized_format(%NaiveDateTime{} = date_time, timezone, output_format) do
    date_time
    |> NaiveDateTime.to_erl()
    |> Timex.to_datetime(timezone)
    |> Timex.Timezone.convert("UTC")
    |> Timex.format!(output_format)
  end

  @doc """
  Returns the current UTC date time in HL7 format (YYYYMMDDHHMMSS+0000)
  """
  def get_current_date_time() do
    Timex.now() |> to_hl7_string()
  end

  @doc """
  Returns the current date time in a specified timezone in HL7 format (YYYYMMDDHHMMSS+0600)

  ## Parameters

  - timezone: Timezone to create the date time in
  """
  def get_current_date_time(timezone) do
    Timex.now(timezone) |> to_hl7_string()
  end

  defp to_hl7_string(%DateTime{} = timex_time) do
    Timex.format!(timex_time, "{YYYY}{0M}{0D}{h24}{m}{s}{Z}")
  end
end
