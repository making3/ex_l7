defmodule ExL7.Date do
  @moduledoc """
  Helper functions for HL7 date times
  """

  @doc """
  Returns the current UTC date time in HL7 format (YYYYMMDDHHMMSS+0000)
  """
  def get_current_date_time() do
    Timex.now() |> format()
  end

  @doc """
  Returns the current date time in a specified timezone in HL7 format (YYYYMMDDHHMMSS+0600)

  ## Parameters

  - timezone: Timezone to create the date time in
  """
  def get_current_date_time(timezone) do
    Timex.now(timezone) |> format()
  end

  defp format(timex_time) do
    Timex.format!(timex_time, "{YYYY}{0M}{0D}{h24}{m}{s}{Z}")
  end
end
