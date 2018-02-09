defmodule ExL7.ValidationTest do
  use ExUnit.Case
  doctest ExL7.Validation

  import ExL7.Validation

  describe "validate" do
    test "invalid header" do
      expected = {:error, "Invalid Header"}
      assert validate("M") == expected
      assert validate("MSH") == expected
      assert validate("MSH|a") == expected
      assert validate("M|aa") == expected
      assert validate("M|aaa") == expected
      assert validate("M|123456") == expected
      assert validate("M|1|") == expected
      assert validate("M|11|") == expected
      assert validate("M|111|") == expected
      assert validate("M|1234|") == expected
    end

    test "no segments" do
      expected = {:error, "No Segments Found"}
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4") == expected
    end

    test "invalid segments" do
      expected = {:error, "Invalid Segment(s)"}
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID:234") == expected
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID234") == expected
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID123|123|") == expected
    end

    test "valid segments" do
      expected = {:ok, %ExL7.Message{}}
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID\rXFA") == expected
      assert validate("MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\rPID|") == expected
      assert validate("MSH:^~\\&:ExL7:iWT Health::1:::ORU^R01::T:2.4\rPID:") == expected
    end
  end
end
