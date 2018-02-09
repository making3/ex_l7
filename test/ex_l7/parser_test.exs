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
end
