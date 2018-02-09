defmodule ExL7.SegmentTest do
  use ExUnit.Case
  doctest ExL7.Segment

  import ExL7.Segment
  alias ExL7.Segment
  alias ExL7.Field

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
