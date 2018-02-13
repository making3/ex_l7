defmodule ExL7.Ack.Config do
  defstruct control_characters: %ExL7.ControlCharacters{},
            sending_application: "ExL7",
            sending_facility: "iWT Health",
            security: "",
            message_event: "",
            processing_id: "D",
            version: "2.3"

  def get_current_date_time() do
    Timex.now() |> Timex.format!("{YYYY}{0M}{0D}{h24}{m}{s}")
  end
end
