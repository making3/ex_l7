defmodule ExL7.QueryParserTest do
  use ExUnit.Case
  doctest ExL7.QueryParser

  import ExL7.QueryParser

  describe "single segment" do
    test "field" do
      query = parse("PID|1")

      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == "field"
      assert query.is_date == false
    end

    test "component" do
      query = parse("PID|1^0")
      assert query.segment == "PID"
      assert query.field == "field"
      assert query.component == 0
      assert query.is_date == false
    end

    test "component repetition" do
      query = parse("PID|1^0[3]")
      assert query.repeat == 3
      assert query.is_date == false
    end
  end

  describe "multi segment" do
    test "field" do
      query = parse("PID[1]")
      assert query.all_segments == true
      assert query.segment == "PID"
      assert query.field == 1
      assert query.is_date == false
    end

    test "component" do
      query = parse("PID|3[1]")
      assert query.all_segments == true
      assert query.segment == "PID"
      assert query.field == 3
      assert query.component == 1
      assert query.is_date == false
    end
  end

  describe "sub components" do
    test "basic" do
      query = parse("PID|1^0&2")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 1
      assert query.component == 0
      assert query.sub_component == 2
      assert query.is_date == false
    end

    test "repitition" do
      query = parse("PID|1^0&3[4]")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 1
      assert query.component == 0
      assert query.sub_component == 3
      assert query.repeat == 4
      assert query.is_date == false
    end

    test "match" do
      query = parse("PID|1(4,MR)^7&8")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 1
      assert query.component == 7
      assert query.sub_component == 8
      assert query.is_date == false
    end
  end

  describe "field selectors" do
    test "field" do
      query = parse("PID|1(4,MR)")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 1
      assert query.component_match.component == 4
      assert query.component_match.value == "MR"
      assert query.is_date == false
    end

    test "field with spaces" do
      query = parse("PV1|18(2,MR FIN)")
      assert query.all_segments == false
      assert query.segment == "PV1"
      assert query.field == 18
      assert query.component_match.component == 2
      assert query.component_match.value == "MR FIN"
      assert query.is_date == false
    end

    test "component" do
      query = parse("PID|3(5,RN)^6")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 3
      assert query.component_match.component == 5
      assert query.component_match.value == "RN"
      assert query.component == 6
      assert query.is_date == false
    end

    test "component with spaces" do
      query = parse("PID|10(0,MR OTHER SPACE)^8")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 10
      assert query.component_match.component == 0
      assert query.component_match.value == "MR OTHER SPACE"
      assert query.component == 8
      assert query.is_date == false
    end
  end

  describe "date format" do
    test "field" do
      query = parse("@PID|1")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 1
      assert query.is_date == true
    end

    test "component" do
      query = parse("@PID|2^2")
      assert query.all_segments == false
      assert query.segment == "PID"
      assert query.field == 2
      assert query.component == 2
      assert query.is_date == true
    end

    test "sub_component" do
      query = parse("@PV1|3^22&0")
      assert query.all_segments == false
      assert query.segment == "PV1"
      assert query.field == 3
      assert query.component == 22
      assert query.sub_component == 22
      assert query.is_date == true
    end

    test "multi field" do
      query = parse("@PV1[4]")
      assert query.all_segments == true
      assert query.segment == "PV1"
      assert query.field == 4
      assert query.is_date == true
    end

    test "multi component" do
      query = parse("@PV1|5[6]")
      assert query.all_segments == true
      assert query.segment == "PV1"
      assert query.field == 5
      assert query.component == 6
      assert query.is_date == true
    end
  end

  describe "invalid" do
    setup do
      {:invalid_query, {:error, "Invalid Query"}}
    end

    test "empty", context do
      assert parse("") == context[:invalid_query]
    end

    test "segment only", context do
      assert parse("PID") == context[:invalid_query]
    end

    test "invalid segment", context do
      assert parse("PID3|3") == context[:invalid_query]
    end

    test "invalid field", context do
      assert parse("PID|a") == context[:invalid_query]
    end

    test "multi multi", context do
      assert parse("PId[4][4][5]") == context[:invalid_query]
    end
  end
end
