#
# == overseer_api.ex
#
# This module contains the GenServer for a system module to interact with the Overseer system module
#
require Logger

defmodule OpenAperture.OverseerApi.Publisher do
	use GenServer

  @logprefix "[OverseerApi][Publisher]"

  @moduledoc """
  This module contains the GenServer for a system module to interact with the Overseer system module
  """  

  alias OpenAperture.Messaging.ConnectionOptionsResolver
  alias OpenAperture.Messaging.AMQP.QueueBuilder

  alias OpenAperture.ManagerApi

  alias OpenAperture.OverseerApi.Events.Event
  alias OpenAperture.OverseerApi.Request

  alias OpenAperture.OverseerApi.ModuleRegistration

	@connection_options nil
	use OpenAperture.Messaging

  @doc """
  Specific start_link implementation

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t()}	
  def start_link() do
    Logger.debug("#{@logprefix} Starting...")

    state = %{
      exchange_id: Application.get_env(:openaperture_overseer_api, :exchange_id),
      broker_id: Application.get_env(:openaperture_overseer_api, :broker_id),
    }
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Method to publish Events to the Overseer

  ## Option Values

  The `event` module represents the Event to publish

  ## Return Value

  :ok
  """
  @spec publish_event(Event.t) :: :ok
  def publish_event(event) do
  	GenServer.cast(__MODULE__, {:publish_event, event})
	end

  def publish_request(request) do
    GenServer.cast(__MODULE__, {:publish_request, request})
  end

  @doc """
  GenServer callback for handling the :publish_event event.  This method
  will publish events to the Overseer system module

  {:noreply, state}
  """
  @spec handle_cast({:publish_event, Event.t}, Map) :: {:noreply, Map}
  def handle_cast({:publish_event, event}, state) do
    Logger.debug("#{@logprefix} Publishing #{inspect Event.type(event)} event to Overseer...")

    module = ModuleRegistration.get_module

    payload = Map.from_struct(event)
    payload = Map.put(payload, :hostname, module[:hostname])
    payload = Map.put(payload, :type, module[:type])
    payload = Map.put(payload, :event_type, Event.type(event))
    
		options = ConnectionOptionsResolver.get_for_broker(ManagerApi.get_api, state[:broker_id])
		event_queue = QueueBuilder.build(ManagerApi.get_api, "system_modules", state[:exchange_id])

		case publish(options, event_queue, payload) do
			:ok -> Logger.debug("#{@logprefix} Successfully published Overseer #{inspect Event.type(event)} event")
			{:error, reason} -> Logger.error("#{@logprefix} Failed to publish Overseer #{inspect Event.type(event)} event:  #{inspect reason}")
		end
    {:noreply, state}
  end

  @doc """
  GenServer callback for handling the :publish_request event.  This method
  will publish requests to the Overseer system module

  {:noreply, state}
  """
  @spec handle_cast({:publish_request, Request.t}, Map) :: {:noreply, Map}
  def handle_cast({:publish_request, request}, state) do
    Logger.debug("#{@logprefix} Publishing request to Overseer...")

    payload = Request.to_payload(request)
    
    options = ConnectionOptionsResolver.get_for_broker(ManagerApi.get_api, state[:broker_id])
    queue = QueueBuilder.build(ManagerApi.get_api, "overseer", state[:exchange_id])

    case publish(options, queue, payload) do
      :ok -> Logger.debug("[#{@logprefix} Successfully published request to Overseer")
      {:error, reason} -> Logger.error("#{@logprefix} Failed to publish request to Overseer:  #{inspect reason}")
    end
    {:noreply, state}
  end
end