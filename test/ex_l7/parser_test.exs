defmodule ExL7.ParserTest do
  use ExUnit.Case
  doctest ExL7.Parser

  import ExL7.Parser

  describe "parse" do
    # TODO: Implementation
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
end
