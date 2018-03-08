defmodule ExL7.SegmentTest do
  use ExUnit.Case
  doctest ExL7.Segment

  import ExL7.Segment
  alias ExL7.Segment
  alias ExL7.Field

  describe "parse" do
    test "parse single field" do
      actual = parse("PID|foo", %ExL7.ControlCharacters{})
      assert length(actual.fields) == 2

      pid = Enum.at(actual.fields, 0)
      assert pid.components == ["PID"]

      foo = Enum.at(actual.fields, 1)
      assert foo.components == ["foo"]
    end

    test "parse repeated fields" do
      actual = parse("PID|foo~bar~test", %ExL7.ControlCharacters{})
      assert length(actual.fields) == 2

      pid = Enum.at(actual.fields, 0)
      assert pid.components == ["PID"]

      repeated = Enum.at(actual.fields, 1)
      assert length(repeated) == 3
      assert Enum.at(repeated, 0).components == ["foo"]
      assert Enum.at(repeated, 1).components == ["bar"]
      assert Enum.at(repeated, 2).components == ["test"]
    end
  end

  describe "get_id" do
    test "should return the first field" do
      segment = %Segment{fields: [%Field{components: ["PID"]}]}
      assert get_id(segment) == "PID"
    end
  end

  describe "to_string" do
    test "full segment string" do
      fields = [
        %Field{components: ["PID"]},
        %Field{components: ["asdfasd"]},
        [
          %Field{components: ["1111", ["AA", "CC"]]},
          %Field{components: ["2222", ["BB", "DD"]]}
        ]
      ]

      segment = %Segment{fields: fields}
      control_characters = %ExL7.ControlCharacters{}
      expected = "PID|asdfasd|1111^AA&CC~2222^BB&DD"
      actual = to_string(segment, control_characters)
      assert actual == expected
    end
  end
end
