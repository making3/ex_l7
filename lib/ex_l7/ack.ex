defmodule ExL7.Ack do
  @moduledoc """
  Provides functions to generate HL7 acknowledgement messages
  """

  import ExL7.Message.Header

  @doc """
  Returns an HL7 acknowledgement message as a string
  """
  def acknowledge(%ExL7.Message{} = l7_message, sequence) do
    get_ack_hl7(l7_message, sequence, "AA")
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with AE as the code.
  """
  def error(l7_message_or_ack_config, sequence, reason \\ "")

  def error(%ExL7.Message{} = l7_message, sequence, reason) do
    get_ack_hl7(l7_message, sequence, "AE", reason)
  end

  def error(%ExL7.Ack.Config{} = ack_config, sequence, reason) do
    get_ack_hl7(ack_config, sequence, "AR", reason)
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with AR as the code.
  """
  def reject(l7_message_or_ack_config, sequence, reason \\ "")

  def reject(%ExL7.Message{} = l7_message, sequence, reason) do
    get_ack_hl7(l7_message, sequence, "AR", reason)
  end

  def reject(%ExL7.Ack.Config{} = ack_config, sequence, reason) do
    get_ack_hl7(ack_config, sequence, "AR", reason)
  end

  @doc """
  Returns an HL7 negative acknowledgement message as a string with a custom code
  """
  def other(l7_message_or_ack_config, sequence, code, reason \\ "")

  def other(%ExL7.Message{} = l7_message, sequence, code, reason) do
    get_ack_hl7(l7_message, sequence, code, reason)
  end

  def other(%ExL7.Ack.Config{} = ack_config, sequence, code, reason) do
    get_ack_hl7(ack_config, sequence, code, reason)
  end

  defp get_ack_hl7(%ExL7.Message{} = l7_message, sequence, code, reason \\ "") do
    get_msh_segment(l7_message, sequence) <>
      l7_message.control_characters.segment <> get_msa_segment(l7_message, code, reason)
  end

  defp get_msh_segment(%ExL7.Ack.Config{} = ack_config, sequence) do
    Enum.join(
      [
        "MSH",
        get_control_characters(ack_config.control_characters),
        ack_config.sending_application,
        ack_config.sending_application,
        "",
        "",
        ExL7.Ack.Config.get_current_date_time(),
        "",
        "ACK" <> ack_config.control_characters.component <> ack_config.message_event,
        sequence,
        ack_config.processing_id,
        ack_config.version
      ],
      ack_config.control_characters.field
    )
  end

  defp get_msh_segment(%ExL7.Message{} = l7_message, sequence) do
    Enum.join(
      [
        "MSH",
        get_control_characters(l7_message),
        get_application(l7_message),
        get_facility(l7_message),
        get_sending_application(l7_message),
        get_sending_facility(l7_message),
        ExL7.Ack.Config.get_current_date_time(),
        "",
        "ACK" <> l7_message.control_characters.component <> get_message_event(l7_message),
        sequence,
        get_processing_id(l7_message),
        get_version(l7_message)
      ],
      l7_message.control_characters.field
    )
  end

  defp get_msa_segment(%ExL7.Ack.Config{} = ack_config, code, reason) do
    Enum.join(
      [
        "MSA",
        code,
        "",
        reason
      ],
      ack_config.control_characters.field
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
end
