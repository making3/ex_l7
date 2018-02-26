defmodule ExL7.DateTest do
  use ExUnit.Case
  doctest ExL7.Date

  import ExL7.Date

  describe "convert" do
    test "date only" do
      actual =
        "20180202"
        |> convert()
        |> format("{YYYY}-{0M}-{0D}")

      assert actual == "2018-02-02"
    end

    test "date with hour" do
      actual =
        "2018020211"
        |> convert()
        |> format("{YYYY}-{0M}-{0D} {h24}:{m}:{s}")

      assert actual == "2018-02-02 11:00:00"
    end

    test "date with time" do
      actual =
        "201802020119"
        |> convert()
        |> format("{YYYY}-{0M}-{0D} {h24}:{m}:{s}")

      assert actual == "2018-02-02 01:19:00"
    end

    test "date with timestamp" do
      actual =
        "20180202011933"
        |> convert()
        |> format("{YYYY}-{0M}-{0D} {h24}:{m}:{s}")

      assert actual == "2018-02-02 01:19:33"
    end
  end
end
