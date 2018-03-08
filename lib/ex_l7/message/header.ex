defmodule ExL7.Message.Header do
  @moduledoc """
  Helper functions for retrieving HL7 message header information
  """

  import ExL7.Query

  def get_control_characters(%ExL7.Message{control_characters: chars}) do
    get_control_characters(chars)
  end

  def get_control_characters(%ExL7.ControlCharacters{} = chars) do
    chars.component <> chars.repeat <> chars.escape <> chars.sub_component
  end

  def get_sending_application(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|2")
  end

  def get_sending_facility(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|3")
  end

  def get_receiving_application(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|4")
  end

  def get_receiving_facility(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|5")
  end

  def get_date_time(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|6")
  end

  def get_security(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|7")
  end

  def get_message_type(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|8^0")
  end

  def get_message_event(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|8^1")
  end

  def get_control_id(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|9")
  end

  def get_processing_id(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|10")
  end

  def get_version(%ExL7.Message{} = l7_message) do
    query(l7_message, "MSH|11")
  end
end
