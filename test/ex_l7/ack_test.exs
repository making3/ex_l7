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
      ack_string = acknowledge(context[:l7_message], "seq1")
      {:ok, actual} = ExL7.parse(ack_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "seq1"
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

      ack_string = acknowledge(received, "asdf")
      {:ok, actual} = ExL7.parse(ack_string)

      assert query(actual, "MSH|2") == "ExL7"
      assert query(actual, "MSH|3") == "iWT Health"
    end
  end

  describe "error" do
    test "generate app error hl7 no reason", context do
      nak_string = error(context[:l7_message], "seq23")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "seq23"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AE"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "generate app error hl7 with reason", context do
      nak_string = error(context[:l7_message], "sqcb", "code broke")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSA|1") == "AE"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == "code broke"
    end
  end

  describe "reject" do
    test "generate app reject hl7 no reason", context do
      nak_string = reject(context[:l7_message], "sq4")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "sq4"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AR"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "generate app reject hl7 with reason", context do
      nak_string = reject(context[:l7_message], "seqbad", "bad msh")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSA|1") == "AR"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == "bad msh"
    end
  end

  describe "other" do
    test "generate custom ack an hl7 with no reason", context do
      nak_string = other(context[:l7_message], "sqd5", "AZ")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSH|2") == "RandomApp"
      assert query(actual, "MSH|3") == "Fac2"
      assert query(actual, "MSH|4") == "ExL7"
      assert query(actual, "MSH|5") == "iWT Health"
      assert query(actual, "MSH|7") == ""
      assert query(actual, "MSH|8") == "ACK^R01"
      assert query(actual, "MSH|9") == "sqd5"
      assert query(actual, "MSH|10") == "T"
      assert query(actual, "MSH|11") == "2.4"

      assert query(actual, "MSA|1") == "AZ"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == ""
    end

    test "generate custom ack an hl7 with reason", context do
      nak_string = other(context[:l7_message], "sqq6", "RR", "random response")
      {:ok, actual} = ExL7.parse(nak_string)

      assert query(actual, "MSA|1") == "RR"
      assert query(actual, "MSA|2") == "AF456"
      assert query(actual, "MSA|3") == "random response"
    end
  end
end
