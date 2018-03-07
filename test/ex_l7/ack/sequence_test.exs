defmodule ExL7.Ack.SequenceTest do
  use ExUnit.Case
  doctest ExL7.Ack.Sequence

  import ExL7.Ack.Sequence

  test "two sequences should not be the same" do
    {:ok, sequencer} = start_link()
    assert get_next(sequencer) != get_next(sequencer)
  end

  test "sequence counter should increase" do
    {:ok, sequencer} = start_link()
    sequence1 = String.slice(get_next(sequencer), -1..-1)
    sequence2 = String.slice(get_next(sequencer), -1..-1)

    assert sequence1 != sequence2
  end
end
