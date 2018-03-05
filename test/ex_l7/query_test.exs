defmodule ExL7.QueryTest do
  use ExUnit.Case
  doctest ExL7.Query

  import ExL7.Query
  alias ExL7.Parser
  alias ExL7.Query.DateOptions

  setup do
    {:ok, parsed} =
      Parser.parse(
        "MSH|^~\\&|ExL7|iWT Health||1|20150912110538||ORU^R01|5555^4444&P&FF|T|2.4\r" <>
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

    test "basic query - sub_component", context do
      actual = query(context[:parsed], "MSH|9^1&2")
      assert actual == "FF"
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

  describe "query - datetime (timezone)" do
    test "2015-09-12 11:05:38 from @MSH|6", context do
      actual = query(context[:parsed], "@MSH|6")
      assert actual == "2015-09-12 11:05:38"
    end

    test "2016-12-02 00:30:24 from @ZB2|1^1", context do
      actual = query(context[:parsed], "@ZB2|1^1")
      assert actual == "2016-12-02 00:30:24"
    end

    test "2016-12-02 12:30:24 from @MSH|6 with America/Chicago timezone" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20161202063024||ORU^R01|5555|T|2.4\rPID|1")

      actual = query(parsed, "@MSH|6", %DateOptions{timezone: "America/Chicago"})
      assert actual == "2016-12-02 12:30:24"
    end

    test "2016-06-02 11:30:24 from @MSH|6 with America/Chicago timezone" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160602063024||ORU^R01|5555|T|2.4\rPID|1")

      actual = query(parsed, "@MSH|6", %DateOptions{timezone: "America/Chicago"})
      assert actual == "2016-06-02 11:30:24"
    end

    test "2016-12-02 12:30:24 from @MSH|6 containing 0600 offset" do
      {:ok, parsed} =
        Parser.parse(
          "MSH|^~\\&|ExL7|iWT Health||1|20161202063024.213-0600||ORU^R01|5555|T|2.4\rPID|1"
        )

      actual = query(parsed, "@MSH|6")
      assert actual == "2016-12-02 12:30:24"
    end

    test "2016-06-02 00:30:24 from @MSH|6 containing 0400 offset" do
      {:ok, parsed} =
        Parser.parse(
          "MSH|^~\\&|ExL7|iWT Health||1|20160602043024.2+0400||ORU^R01|5555|T|2.4\rPID|1"
        )

      actual = query(parsed, "@MSH|6")
      assert actual == "2016-06-02 00:30:24"
    end

    test "nothing from @MSH|4 containing no value" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20130802||ORU^R01|5555|T|2.4\rPID||1")

      actual = query(parsed, "@MSH|4")
      assert actual == ""
      actual = query(parsed, "@PID|1")
      assert actual == ""
    end

    test "ExL7 from @MSH|2 with a non-date" do
      {:ok, parsed} =
        Parser.parse(
          "MSH|^~\\&|ExL7|iWT Health||1|20130802||ORU^R01|5555|T|2.4\rPID||190|longer value than 8"
        )

      actual = query(parsed, "@MSH|2")
      assert actual == "ExL7"
      actual = query(parsed, "@PID|2")
      assert actual == "190"
      actual = query(parsed, "@PID|3")
      assert actual == "longer value than 8"
    end

    test "2016-04-02 10:00:00 from @MSH|6 containing date and hour only" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|2016040210||ORU^R01|5555|T|2.4\rPID||")

      actual = query(parsed, "@MSH|6")
      assert actual == "2016-04-02 10:00:00"
    end

    test "2016-04-02 00:30:00 from @MSH|6 containing date and minute only" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|201604020030||ORU^R01|5555|T|2.4\rPID||")

      actual = query(parsed, "@MSH|6")
      assert actual == "2016-04-02 00:30:00"
    end

    test "2016-02-17 06:00:00 from @@MSH|6 with a date only and America/Chicago" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160217||ORU^R01|5555|T|2.4\rPID||")

      actual = query(parsed, "@@MSH|6", %DateOptions{timezone: "America/Chicago"})
      assert actual == "2016-02-17 06:00:00"
    end

    test "2016-06-15 05:00:00 @@MSH|6 from date only and America/Chicago in DST" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160615||ORU^R01|5555|T|2.4\rPID||")

      actual = query(parsed, "@@MSH|6", %DateOptions{timezone: "America/Chicago"})
      assert actual == "2016-06-15 05:00:00"
    end

    test "2016-01-24 00:00:00 from @@MSH|6 and default timezone" do
      {:ok, parsed} =
        Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124||ORU^R01|5555|T|2.4\rPID||")

      actual = query(parsed, "@@MSH|6")
      assert actual == "2016-01-24 00:00:00"
    end
  end

  describe "query - datetime (format)" do
    # test "2016/01/24 000000 from "20160127" with moment" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124||ORU^R01|5555|T|2.4\rPID||")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HHmmss")
    # 		assert actual == "2016/01/24 000000"
    # end
    #
    # test "2016/01/24 060000" from "20160127" with moment" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124||ORU^R01|5555|T|2.4\rPID||")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HHmmss")
    # 		assert actual == "2016/01/24 000000"
    # end
    #
    #
    # test "2016/01/24 134056" from "20160127134056" with moment" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124134056||ORU^R01|5555|T|2.4\rPID||")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HHmmss")
    # 		assert actual == "2016/01/24 134056"
    # end
    #
    # test "2016/01/24 134056" from "20160127134056" with moment and Chicago timezone" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124134056||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HHmmss")
    # 		assert actual == "2016/01/24 194056"
    # end
    #
    # test "2016/01/24" from "20160124" with moment and Chicago timezone" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD")
    # 		assert actual == "2016/01/24"
    # end
    #
    # test "2016/01/24" from "20160124" with moment and Sydney timezone" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|20160124||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'Australia/Sydney")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD")
    # 		assert actual == "2016/01/24"
    # end
    #
    # test "should return 2017-08-14 10:32:00 from 201708140532 (missing seconds)" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|201708140532||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HH:mm:ss")
    # 		assert actual == "2017/08/14 10:32:00"
    # end
    #
    # test "should return 2017-08-14 09:32:00 from 201708140532-0400 (missing seconds)" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|201708140532-0400||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', {""YYYY/MM/DD HH:mm:ss")
    # 		assert actual == "2017/08/14 09:32:00"
    # end
    #
    # test "should return 2017-08-14 10:00:00 from 2017081405 (missing minutes/seconds)" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|2017081405||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HH:mm:ss").should.equal('2017/08/14 10:00:00")
    # end
    #
    # test "should return 2017-08-14 09:00:00 from 2017081405-0400 (missing minutes/seconds)" do
    #     {:ok, parsed} = Parser.parse("MSH|^~\\&|ExL7|iWT Health||1|2017081405-0400||ORU^R01|5555|T|2.4\rPID||',
    #         '\r',
    #         'America/Chicago")
    #     actual = query(parsed, "@MSH|6', "YYYY/MM/DD HH:mm:ss").should.equal('2017/08/14 09:00:00")
    # end
  end
end
