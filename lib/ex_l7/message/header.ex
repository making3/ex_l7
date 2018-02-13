defmodule ExL7.Message.Header do
  @moduledoc """
  Helper functions for retrieving HL7 message header information
  """

  import ExL7.Query

  def get_control_characters(%ExL7.Message{control_characters: chars}) do
    chars.component <> chars.repeat <> chars.escape <> chars.sub_component
  end

  def get_sending_application(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|2")
  end

  def get_sending_facility(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|3")
  end

  def get_receiving_application(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|4")
  end

  def get_receiving_facility(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|5")
  end

  def get_date_time(l7_message = %ExL7.Message{}) do
    # TODO: Date Time formatting
    query(l7_message, "MSH|6")
  end

  def get_security(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|7")
  end

  def get_message_type(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|8^0")
  end

  def get_message_event(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|8^1")
  end

  def get_control_id(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|9")
  end

  def get_processing_id(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|10")
  end

  def get_version(l7_message = %ExL7.Message{}) do
    query(l7_message, "MSH|11")
  end
end
