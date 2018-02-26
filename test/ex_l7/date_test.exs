defmodule ExL7.DateTest do
  use ExUnit.Case
  doctest ExL7.Date

  import ExL7.Date

  describe "convert" do
    test "date only" do
      actual = convert("20180202", "UTC")
      assert actual == "2018-02-02"
    end

    test "date with hour" do
      actual = convert("2018020211", "UTC")
      assert actual == "2018-02-02 11:00:00"
    end

    test "date with time" do
      actual = convert("201802020119", "UTC")
      assert actual == "2018-02-02 01:19:00"
    end

    test "date with timestamp" do
      actual = convert("20180202011933", "UTC")
      assert actual == "2018-02-02 01:19:33"
    end
  end
end
