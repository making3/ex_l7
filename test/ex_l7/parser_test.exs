defmodule ExL7.ParserTest do
  use ExUnit.Case
  doctest ExL7.Parser

  import ExL7.Parser

  describe "validations" do
    test "fail with an empty hl7" do
      expected = {:error, "No Data"}
      assert parse("") == expected
    end

    test "fail with an invalid header" do
      expected = {:error, "Invalid Header"}
      assert parse("M") == expected
      assert parse("MSH") == expected
      assert parse("M|1234|") == expected
    end

    test "no segments" do
      expected = {:error, "No Segments Found"}
      assert parse("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4") == expected
    end

    test "invalid segments" do
      expected = {:error, "Invalid Segment(s)"}
      assert parse("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID:234") == expected
      assert parse("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID234") == expected
      assert parse("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID123|123|") == expected
    end
  end

  describe "read file" do
    test "invalid file" do
      expected = {:error, "Invalid File"}
      assert parse_file("/tmp/foobar2000") == expected
    end

    test "no data" do
      file_name = ".no_data_hl7"
      {:ok, file} = File.open(file_name, [:write])
      File.close(file)

      expected = {:error, "No Data"}
      assert parse_file(file_name) == expected

      File.rm(file_name)
    end

    test "invalid hl7" do
      file_name = ".invalid_hl7"
      {:ok, file} = File.open(file_name, [:write])
      IO.binwrite(file, "MSH|")
      File.close(file)

      expected = {:error, "Invalid Header"}
      assert parse_file(file_name) == expected

      File.rm(file_name)
    end
  end

  describe "parse" do
    setup do
      hl7 =
        "MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\r" <>
          "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r" <>
          "OBX|1|doc^foo\r" <> "OBX|2|doc^idk"

      {:ok, hl7: hl7}
    end

    test "get new ExL7.Message", context do
      {:ok, message} = parse(context[:hl7])
      assert message.timezone == "UTC"
      assert length(message.segments) == 4

      msh_fields = Enum.at(message.segments, 0)
      assert length(msh_fields.fields) == 12

      pid_fields = Enum.at(message.segments, 1)
      assert length(pid_fields.fields) == 3

      obx1_fields = Enum.at(message.segments, 2)
      assert length(obx1_fields.fields) == 3

      obx2_fields = Enum.at(message.segments, 3)
      assert length(obx2_fields.fields) == 3
    end

    test "set timezone on ExL7 Message", context do
      {:ok, result} = parse(context[:hl7], "\r", "America/Chicago")
      assert result.timezone == "America/Chicago"
    end
  end
end
