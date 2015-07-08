defmodule OpenAperture.OverseerApi.PublisherTest do
  use ExUnit.Case

  alias OpenAperture.OverseerApi.Publisher
  alias OpenAperture.OverseerApi.Events.Status, as: StatusEvent
  alias OpenAperture.OverseerApi.Request

  alias OpenAperture.Messaging.ConnectionOptionsResolver
  alias OpenAperture.Messaging.AMQP.ConnectionOptions, as: AMQPConnectionOptions

  alias OpenAperture.Messaging.AMQP.QueueBuilder
  alias OpenAperture.Messaging.AMQP.ConnectionPool
  alias OpenAperture.Messaging.AMQP.ConnectionPools

  #=========================
  # handle_cast({:publish_event}) tests

  test "handle_cast({:publish_event}) - success" do
  	:meck.new(ConnectionPools, [:passthrough])
  	:meck.expect(ConnectionPools, :get_pool, fn _ -> %{} end)

  	:meck.new(ConnectionPool, [:passthrough])
  	:meck.expect(ConnectionPool, :publish, fn _, _, _, _ -> :ok end)

    :meck.new(QueueBuilder, [:passthrough])
    :meck.expect(QueueBuilder, :build, fn _,_,_ -> %OpenAperture.Messaging.Queue{name: ""} end)      

    :meck.new(ConnectionOptionsResolver, [:passthrough])
    :meck.expect(ConnectionOptionsResolver, :get_for_broker, fn _, _ -> %AMQPConnectionOptions{} end)

  	state = %{
  	}

    event = %StatusEvent{
      status: :active,
      workload: ["something"]
    }
    assert Publisher.handle_cast({:publish_event, event}, state) == {:noreply, state}
  after
  	:meck.unload(ConnectionPool)
  	:meck.unload(ConnectionPools)
    :meck.unload(QueueBuilder)
    :meck.unload(ConnectionOptionsResolver)        
  end

  #=========================
  # handle_cast({:publish_request}) tests

  test "handle_cast({:publish_request}) - success" do
    :meck.new(ConnectionPools, [:passthrough])
    :meck.expect(ConnectionPools, :get_pool, fn _ -> %{} end)

    :meck.new(ConnectionPool, [:passthrough])
    :meck.expect(ConnectionPool, :publish, fn _, _, _, _ -> :ok end)

    :meck.new(QueueBuilder, [:passthrough])
    :meck.expect(QueueBuilder, :build, fn _,_,_ -> %OpenAperture.Messaging.Queue{name: ""} end)      

    :meck.new(ConnectionOptionsResolver, [:passthrough])
    :meck.expect(ConnectionOptionsResolver, :get_for_broker, fn _, _ -> %AMQPConnectionOptions{} end)

    state = %{
    }

    request = %Request{
      action: :upgrade_request,
      options: %{force: true}
    }
    assert Publisher.handle_cast({:publish_request, request}, state) == {:noreply, state}
  after
    :meck.unload(ConnectionPool)
    :meck.unload(ConnectionPools)
    :meck.unload(QueueBuilder)
    :meck.unload(ConnectionOptionsResolver)        
  end
end
