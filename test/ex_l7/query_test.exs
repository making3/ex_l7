defmodule ExL7.QueryTest do
  use ExUnit.Case
  doctest ExL7.Query

  import ExL7.Query
  alias ExL7.Parser

  setup do
    {:ok, parsed} =
      Parser.parse(
        "MSH|^~\\&|Sora|iWT Health||1|20150912110538||ORU^R01|5555|T|2.4\r" <>
          "PID|123^MR~456^AN~~foo^lots^333^234^^more|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby~Spaced Value^777^Rosser&Bobber||testvalue\r" <>
          "OBX|1|doc^foo\r" <>
          "OBX|2|doc^idk\r\n" <>
          "GV1|65\r\n" <> "ZB2|comp1^20161202003024|20161202063024|20160602063024\r\n"
      )

    {:ok, parsed: parsed}
  end

  describe "query" do
    test "basic query", context do
      actual = query(context[:parsed], "MSH|3")
      assert actual == "iWT Health"

      actual = query(context[:parsed], "MSH|11")
      assert actual == "2.4"

      actual = query(context[:parsed], "GV1|1")
      assert actual == "65"
    end

    test "basic query - component", context do
      actual = query(context[:parsed], "MSH|8^1")
      assert actual == "R01"
    end

    test "large numbers", context do
      actual = query(context[:parsed], "MSH|234234")
      assert actual == ""
    end

    test "segments that are not found", context do
      actual = query(context[:parsed], "Z01|45")
      assert actual == ""

      actual = query(context[:parsed], "Z01|45^7")
      assert actual == ""

      actual = query(context[:parsed], "Z91|45(45,MR)^0&123")
      assert actual == ""
    end

    test "[ 123^MR , 456^AN ] from PID|1", context do
      actual = query(context[:parsed], "PID|1")
      assert length(actual) == 4
      assert Enum.at(actual, 0) == "123^MR"
      assert Enum.at(actual, 1) == "456^AN"
      assert Enum.at(actual, 2) == ""
      assert Enum.at(actual, 3) == "foo^lots^333^234^^more"
    end

    test "[ MR, AN ] from PID|1^1", context do
      actual = query(context[:parsed], "PID|1^1")
      assert length(actual) == 4
      assert Enum.at(actual, 0) == "MR"
      assert Enum.at(actual, 1) == "AN"
      assert Enum.at(actual, 2) == ""
      assert Enum.at(actual, 3) == "lots"
    end

    test "AN from PID|1^1[1]", context do
      actual = query(context[:parsed], "PID|1^1[1]")
      assert actual == "AN"
    end

    test "[ 1, 2 ] from OBX[1]", context do
      actual = query(context[:parsed], "OBX[1]")
      assert length(actual) == 2
      assert Enum.at(actual, 0) == "1"
      assert Enum.at(actual, 1) == "2"
    end

    test "[ foo, idk ] from OBX|2[1]", context do
      actual = query(context[:parsed], "OBX|2[1]")
      assert length(actual) == 2
      assert Enum.at(actual, 0) == "foo"
      assert Enum.at(actual, 1) == "idk"
    end

    test "123^MR from PID|1(1,MR)", context do
      actual = query(context[:parsed], "PID|1(1,MR)")
      IO.inspect(actual, label: "actual")
      assert actual == "123^MR"
    end

    test "456 from PID|1(1,AN)^0", context do
      actual = query(context[:parsed], "PID|1(1,AN)^0")
      assert actual == "456"
    end

    test "\"more\" from PID|1(1,lots)^5", context do
      actual = query(context[:parsed], "PID|1(1,lots)^5")
      assert actual == "more"
    end

    test "nothing from PID|1(1,doesnotexist)^8", context do
      actual = query(context[:parsed], "PID|1(1,doesnotexits)^8")
      assert actual == ""
    end

    test "nothing from PID|4(4,AN)^0", context do
      actual = query(context[:parsed], "PID|4(4,AN)^0")
      assert actual == ""
    end

    test "nothing from PID|111111111", context do
      actual = query(context[:parsed], "PID|111111111")
      assert actual == ""
    end

    test "Hill&Bobby when calling PID|2(0,RefDoc)^3", context do
      actual = query(context[:parsed], "PID|2(0,RefDoc)^2")
      assert actual == "Hill&Bobby"

      actual = query(context[:parsed], "PID|2(0,AttDoc)^2")
      assert actual == "Ross&Bob"
    end

    test "Ross when calling PID|2(0,AttDoc)^3&0", context do
      actual = query(context[:parsed], "PID|2(0,AttDoc)^2&0")
      assert actual == "Ross"

      actual = query(context[:parsed], "PID|2(0,AttDoc)^2&1")
      assert actual == "Bob"
    end

    test "Ross when calling PID|2(0,Spaced Value)^3&0", context do
      actual = query(context[:parsed], "PID|2(0,Spaced Value)^2&0")
      assert actual == "Rosser"

      actual = query(context[:parsed], "PID|2(0,Spaced Value)^2&1")
      assert actual == "Bobber"
    end

    test "no value when calling PID|3(3,EPI)^0 with an empty field", context do
      actual = query(context[:parsed], "PID|3(3,EPI)^0")
      assert actual == ""
    end
  end
end
