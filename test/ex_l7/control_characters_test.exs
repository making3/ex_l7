defmodule ExL7.ControlCharactersTest do
  use ExUnit.Case
  doctest ExL7.ControlCharacters

  import ExL7.ControlCharacters

  describe "get_control_characters" do
    test "default segment" do
      chars = get_control_characters("MSH|^~\\&|")
      assert chars.segment === "\r"
      assert chars.field === "|"
      assert chars.component === "^"
      assert chars.repeat === "~"
      assert chars.escape === "\\"
      assert chars.sub_component === "&"
    end

    test "different segment" do
      chars = get_control_characters("MSH|^~\\&|", "\n")
      assert chars.segment === "\n"
    end
  end
end
