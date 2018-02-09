defmodule ExL7.MessageTest do
  use ExUnit.Case
  doctest ExL7.Message

  import ExL7.Message
  alias ExL7.Message
  alias ExL7.Segment
  alias ExL7.Field

  setup do
    hl7 =
      "MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\r" <>
        "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r"

    {:ok, hl7: hl7}
  end

  describe "to_string" do
    test "raw message", context do
      msg = %Message{
        segments: [
          %Segment{
            fields: [
              %Field{components: ["MSH"]},
              %Field{components: ["^~\\&"]},
              %Field{components: ["ExL7"]},
              %Field{components: ["iWT Health"]},
              %Field{},
              %Field{components: ["1"]},
              %Field{},
              %Field{},
              %Field{components: ["ORU", "R01"]},
              %Field{},
              %Field{components: ["T"]},
              %Field{components: ["2.4"]}
            ]
          },
          %Segment{
            fields: [
              %Field{components: ["PID"]},
              [
                %Field{components: ["123", "MR"]},
                %Field{components: ["456", "AN"]}
              ],
              [
                %Field{components: ["AttDoc", "888", ["Ross", "Bob"]]},
                %Field{components: ["RefDoc", "999", ["Hill", "Bobby"]]}
              ]
            ]
          }
        ]
      }

      actual = to_string(msg, %ExL7.ControlCharacters{})
      assert actual == context[:hl7]
    end
  end
end
