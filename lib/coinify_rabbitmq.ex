defmodule CoinifyRabbitmq do
  @moduledoc """
  Documentation for `CoinifyRabbitmq`.
  """

  def register_consumer(event) do
    CoinifyRabbitmq.Consumer.start_link(event)
  end
end
