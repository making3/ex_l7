defmodule ExL7.FieldTest do
  use ExUnit.Case
  doctest ExL7.Field

  import ExL7.Field
  alias ExL7.Field
  alias ExL7.Query

  setup do
    {:ok, control_characters: %ExL7.ControlCharacters{}}
  end

  describe "parse" do
    test "parse single component", context do
      actual = parse("123", context[:control_characters])
      assert actual.components === ["123"]
    end

    test "parse multiple components", context do
      actual = parse("123^4^abc", context[:control_characters])
      assert actual.components === ["123", "4", "abc"]
    end

    test "parse single component with sub components", context do
      actual = parse("Ross&Bob&MD", context[:control_characters])
      assert actual.components === [["Ross", "Bob", "MD"]]
    end

    test "parse multiple components with sub components", context do
      actual = parse("123^4^abc&7^foo&bar&other", context[:control_characters])
      assert actual.components === ["123", "4", ["abc", "7"], ["foo", "bar", "other"]]
    end

    test "parse repeated fields", context do
      actual =
        parse(["AttDoc^888^Ross&Bob", "RefDoc^999^Hill&Bobby"], context[:control_characters])

      assert length(actual) == 2
      bob = Enum.at(actual, 0)
      assert bob.components === ["AttDoc", "888", ["Ross", "Bob"]]

      bobby = Enum.at(actual, 1)
      assert bobby.components === ["RefDoc", "999", ["Hill", "Bobby"]]
    end
  end

  describe "to_string" do
    test "single component", context do
      field = %Field{
        components: ["PID"]
      }

      actual = to_string(field, context[:control_characters])
      assert actual == "PID"
    end

    test "string of components", context do
      field = %Field{
        components: ["acc", "foo", "bar"]
      }

      actual = to_string(field, context[:control_characters])
      assert actual == "acc^foo^bar"
    end

    test "string of components with a sub component", context do
      field = %Field{
        components: ["3333", "2", "45", ["AN", "hh"]]
      }

      actual = to_string(field, context[:control_characters])
      assert actual == "3333^2^45^AN&hh"
    end

    test "string of components with different control characters" do
      field = %Field{
        components: ["111", "2", "65", ["MR", "zz"]]
      }

      control_characters = %ExL7.ControlCharacters{
        component: "*",
        sub_component: "_"
      }

      actual = to_string(field, control_characters)
      assert actual == "111*2*65*MR_zz"
    end

    test "multiple fields", context do
      fields = [
        %Field{
          components: ["111", "2", "65", ["MR", "zz"]]
        },
        %Field{
          components: ["blue", "orange", "no-sub"]
        }
      ]

      actual = to_string(fields, context[:control_characters])
      assert actual == ["111^2^65^MR&zz", "blue^orange^no-sub"]
    end
  end

  describe "get_value" do
    test "get single component", context do
      field = %Field{components: ["111", "2", "65", ["MR", "zz"]]}
      query = %Query{component: 2}
      actual = get_value(field, context[:control_characters], query)
      assert actual == "65"
    end

    test "get component with sub components", context do
      field = %Field{components: ["111", "2", "65", ["MR", "zz"]]}
      query = %Query{component: 3}
      actual = get_value(field, context[:control_characters], query)
      assert actual == "MR&zz"
    end

    test "get specific sub component", context do
      field = %Field{components: ["111", "2", "65", ["MR", "az"]]}
      query = %Query{component: 3, sub_component: 1}
      actual = get_value(field, context[:control_characters], query)
      assert actual == "az"
    end
  end
end
