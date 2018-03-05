defmodule ExL7.Query.DateOptions do
  @moduledoc false
  defstruct timezone: "UTC", format: "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"
end
