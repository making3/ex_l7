defmodule ExL7.AckTest do
  use ExUnit.Case
  doctest ExL7.Ack

  import ExL7.Ack
  import ExL7.Query

  setup do
    {:ok, l7_message} =
      ExL7.parse(
        "MSH|^~\\&|ExL7|iWT Health|RandomApp|Fac2|20091028123702|n/a|ORU^R01|AF456|T|2.4\r" <>
          "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r"
      )

    {:ok, l7_message: l7_message}
  end

  describe "ack" do
    test "generate ack hl7", context do
      ack_string = ack(context[:l7_message])
      {:ok, actual} = ExL7.parse(ack_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "AF456"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AA"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "default sending facility / app" do
      {:ok, received} =
        ExL7.parse(
          "MSH|^~\\&|AdmissionApp|OtherFac|||20091028123702|n/a|ORU^R01|AF456|T|2.4\r" <>
            "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r"
        )

      ack_string = ack(received)
      {:ok, actual} = ExL7.parse(ack_string)

      assert query(actual, "MSH|2") == "ExL7"
      assert query(actual, "MSH|3") == "iWT Health"
    end
  end

  describe "error" do
    test "generate app error hl7 no reason", context do
      nak_string = error(context[:l7_message])
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "AF456"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AE"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "generate app error hl7 with reason", context do
      nak_string = error(context[:l7_message], "code broke")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSA|1") == "AE"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == "code broke"
    end
  end

  describe "reject" do
    test "generate app reject hl7 no reason", context do
      nak_string = reject(context[:l7_message])
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "AF456"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AR"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "generate app reject hl7 with reason", context do
      nak_string = reject(context[:l7_message], "bad msh")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSA|1") == "AR"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == "bad msh"
    end
  end
end
