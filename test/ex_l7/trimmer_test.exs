defmodule ExL7.TrimmerTest do
  use ExUnit.Case
  doctest ExL7.Trimmer

  import ExL7.Trimmer

  describe "trim_segment" do
    test "replace multiple line endings, null values, and tabs" do
      actual = trim_segment("\r\n\t\r\r\t\n\0\r\r\nMSH|foobar\0\r\n\0\r\t\n")
      assert actual == "MSH|foobar"
    end

    test "not replace line endings, null values, and tabs in the middle" do
      value = "MSH|foo\t\r\n\r\0\r\n\n\tbar"
      actual = trim_segment(value)
      assert actual == value
    end
  end
end
