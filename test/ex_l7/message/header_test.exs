defmodule ExL7.Message.HeaderTest do
  use ExUnit.Case
  doctest ExL7.Message.Header

  import ExL7.Message.Header

  setup do
    {:ok, l7_message} =
      ExL7.parse(
        "MSH|^~\\&|ExL7|iWT Health|RandomApp|Fac2|20091028123702|n/a|ORU^R01|AF456|T|2.4\r" <>
          "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r"
      )

    {:ok, l7_message: l7_message}
  end

  test "get_control_characters", context do
    assert get_control_characters(context[:l7_message]) == "^~\\&"
  end

  test "get_sending_application", context do
    assert get_sending_application(context[:l7_message]) == "ExL7"
  end

  test "get_sending_facility", context do
    assert get_sending_facility(context[:l7_message]) == "iWT Health"
  end

  test "get_receiving_application", context do
    assert get_receiving_application(context[:l7_message]) == "RandomApp"
  end

  test "get_receiving_facility", context do
    assert get_receiving_facility(context[:l7_message]) == "Fac2"
  end

  test "get_date_time", context do
    assert get_date_time(context[:l7_message]) == "20091028123702"
  end

  test "get_security", context do
    assert get_security(context[:l7_message]) == "n/a"
  end

  test "get_message_type", context do
    assert get_message_type(context[:l7_message]) == "ORU"
  end

  test "get_message_event", context do
    assert get_message_event(context[:l7_message]) == "R01"
  end

  test "get_control_id", context do
    assert get_control_id(context[:l7_message]) == "AF456"
  end

  test "get_processing_id", context do
    assert get_processing_id(context[:l7_message]) == "T"
  end

  test "get_version", context do
    assert get_version(context[:l7_message]) == "2.4"
  end
end
