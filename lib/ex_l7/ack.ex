defmodule ExL7.Ack do
  @moduledoc """
  Provides functions to generate HL7 acknowledgement messages
  """

  import ExL7.Message.Header

  @doc """
  Returns an HL7 acknowledgement message as a string
  """
  def ack(%ExL7.Message{} = l7_message) do
    get_ack_hl7(l7_message, "AA")
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with AE as the code.
  """
  def error(%ExL7.Message{} = l7_message, reason \\ "") do
    get_ack_hl7(l7_message, "AE", reason)
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with AR as the code.
  """
  def reject(%ExL7.Message{} = l7_message, reason \\ "") do
    get_ack_hl7(l7_message, "AR", reason)
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with a custom code
  """
  def other(%ExL7.Message{} = l7_message, code, reason \\ "") do
    get_ack_hl7(l7_message, code, reason)
  end

  defp get_ack_hl7(%ExL7.Message{} = l7_message, code, reason \\ "") do
    get_msh_segment(l7_message) <>
      l7_message.control_characters.segment <> get_msa_segment(l7_message, code, reason)
  end

  defp get_msh_segment(l7_message = %ExL7.Message{}) do
    Enum.join(
      [
        "MSH",
        get_control_characters(l7_message),
        get_application(l7_message),
        get_facility(l7_message),
        get_sending_application(l7_message),
        get_sending_facility(l7_message),
        get_current_date_time(),
        "",
        "ACK" <> l7_message.control_characters.component <> get_message_event(l7_message),
        get_control_id(l7_message),
        get_processing_id(l7_message),
        get_version(l7_message)
      ],
      l7_message.control_characters.field
    )
  end

  defp get_msa_segment(%ExL7.Message{} = l7_message, code, reason) do
    Enum.join(
      [
        "MSA",
        code,
        get_control_id(l7_message),
        reason
      ],
      l7_message.control_characters.field
    )
  end

  defp get_application(l7_message) do
    application = get_receiving_application(l7_message)

    if application == "" do
      "ExL7"
    else
      application
    end
  end

  defp get_facility(l7_message) do
    facility = get_receiving_facility(l7_message)

    if facility == "" do
      "iWT Health"
    else
      facility
    end
  end

  defp get_current_date_time() do
    Timex.now() |> Timex.format!("{YYYY}{0M}{0D}{h24}{m}{s}")
  end
end
