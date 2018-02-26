defmodule ExL7.Ack.Config do
  defstruct control_characters: %ExL7.ControlCharacters{},
            sending_application: "ExL7",
            sending_facility: "iWT Health",
            security: "",
            message_event: "",
            processing_id: "D",
            version: "2.3"
end
