defmodule CoinifyRabbitmq.Consumer do
  use GenServer
  use AMQP

  @queue_prefix "events.testservice"
  @exchange "events.topic"

  def start_link(event) do
    GenServer.start_link(__MODULE__, [event: event], [])
  end

  def init(opts) do
    {:ok, conn} = Connection.open()
    {:ok, chan} = Channel.open(conn)
    {:ok, queue} = setup_queue(chan, opts)

    {:ok, _consumer_tag} = Basic.consume(chan, queue)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: _tag, redelivered: _redelivered}},
        chan
      ) do
    # You might want to run payload consumption in separate Tasks in production
    IO.puts("Received: #{payload}")
    {:noreply, chan}
  end

  defp setup_queue(chan, opts) do
    event = Keyword.get(opts, :event)
    queue = "#{@queue_prefix}.#{event}"

    {:ok, _} = Queue.declare(chan, queue, durable: true)

    :ok = Exchange.topic(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, queue, @exchange, routing_key: event)
    {:ok, queue}
  end
end
