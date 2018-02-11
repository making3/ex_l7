defmodule ExL7.ComponentTest do
  use ExUnit.Case
  doctest ExL7.Component

  import ExL7.Component
  alias ExL7.ControlCharacters

  test "single string from single component" do
    assert to_string("foo", %ControlCharacters{}) == "foo"
  end

  test "joined string from multiple components" do
    assert to_string(["foo", "bar"], %ControlCharacters{}) == "foo&bar"
  end

  test "joined string from multiple components and different sub_component character" do
    control_characters = %ControlCharacters{sub_component: "!"}
    assert to_string(["blue", "orange"], control_characters) == "blue!orange"
  end
end
