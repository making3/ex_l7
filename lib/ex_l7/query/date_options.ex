defmodule ExL7.Query.DateOptions do
  @moduledoc """
  Options for dates when querying an ExL7.Message.

  ## Keys

  - timezone: The timezone to assume from an HL7 message. Defaults to UTC.
  - The output format for a date. Defaults to {YYYY}-{0M}-{0D} {h24}:{m}:{s}.

  ## Formatting Options

  For formatting options, check out [Timex.DateTime.Formatters](https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Default.html).

  """
  defstruct timezone: "UTC", format: "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"
end
