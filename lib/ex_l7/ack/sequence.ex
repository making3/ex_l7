defmodule ExL7.Ack.Sequence do
  @moduledoc """
  Default sequencing for the ExL7 library.
  """
  use Agent
  alias ExL7.Ack.Config

  def start_link(opts \\ []) do
    Agent.start_link(fn -> 1 end, opts)
  end

  def get_next(sequence_agent) do
    sequence = Agent.get_and_update(sequence_agent, fn state -> {state, state + 1} end)
    Config.get_current_date_time() <> Integer.to_string(sequence)
  end
end
