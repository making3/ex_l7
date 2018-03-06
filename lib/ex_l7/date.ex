defmodule ExL7.Date do
  @moduledoc """
  Helper functions for HL7 date times
  """
  @input_formats [
    "{YYYY}{0M}{0D}",
    "{YYYY}{0M}{0D}{h24}",
    "{YYYY}{0M}{0D}{h24}{Z}",
    "{YYYY}{0M}{0D}{h24}{m}",
    "{YYYY}{0M}{0D}{h24}{m}{Z}",
    "{YYYY}{0M}{0D}{h24}{m}{s}",
    "{YYYY}{0M}{0D}{h24}{m}{s}{Z}",
    "{YYYY}{0M}{0D}{h24}{m}{s}{ss}{Z}"
  ]

  @doc """
  Converts an HL7 specified date to a recognizable date format

  ## Parameters

  - datetime: HL7 string that represents a date time
  - timezone: Timezone that the given date time is in
  """
  def convert(datetime, timezone \\ "UTC") do
    try_convert(datetime, timezone, @input_formats)
  end

  defp try_convert(datetime, _, []) do
    datetime
  end

  defp try_convert(datetime, timezone, [input_format | input_formats]) do
    case Timex.parse(datetime, input_format) do
      {:ok, formatted_datetime} ->
        to_normalized_datetime(formatted_datetime, timezone)

      {:error, _} ->
        try_convert(datetime, timezone, input_formats)
    end
  end

  defp to_normalized_datetime(%DateTime{} = datetime, _) do
    Timex.Timezone.convert(datetime, "UTC")
  end

  defp to_normalized_datetime(%NaiveDateTime{} = datetime, timezone) do
    datetime
    |> NaiveDateTime.to_erl()
    |> Timex.to_datetime(timezone)
    |> Timex.Timezone.convert("UTC")
  end

  def format(%DateTime{} = datetime, output_format) do
    Timex.format!(datetime, output_format)
  end

  def format(invalid_datetime, _) do
    invalid_datetime
  end

  @doc """
  Returns the current UTC date time in HL7 format (YYYYMMDDHHMMSS+0000)
  """
  def get_current_datetime() do
    Timex.now() |> to_hl7_string()
  end

  @doc """
  Returns the current date time in a specified timezone in HL7 format (YYYYMMDDHHMMSS+0600)

  ## Parameters

  - timezone: Timezone to create the date time in
  """
  def get_current_datetime(timezone) do
    Timex.now(timezone) |> to_hl7_string()
  end

  defp to_hl7_string(%DateTime{} = timex_time) do
    Timex.format!(timex_time, "{YYYY}{0M}{0D}{h24}{m}{s}{Z}")
  end
end
