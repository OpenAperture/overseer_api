#
# == overseer_api.ex
#
# This module contains the GenServer for a system module to interact with the Overseer system module
#
require Logger

defmodule OpenAperture.OverseerApi.Heartbeat do
	use GenServer

  alias OpenAperture.OverseerApi.Publisher
  alias OpenAperture.OverseerApi.Events.Status, as: StatusEvent

  @moduledoc """
  This module contains the GenServer for a system module to interact with the Overseer system module
  """  

  @doc """
  Specific start_link implementation

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t()}  
  def start_link() do
    Logger.debug("Starting Heartbeat...")

    case GenServer.start_link(__MODULE__, %{}, []) do
      {:ok, pid} ->
        if Application.get_env(:openaperture_overseer_api, :autostart, true) do
          GenServer.cast(pid, {:publish})
        end
        {:ok, pid}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Method to publish Events to the Overseer

  ## Option Values

  The `event` module represents the Event to publish

  ## Return Value

  :ok
  """
  @spec set_workload(List) :: :ok
  def set_workload(workload) do
    GenServer.call(__MODULE__, {:set_workload, workload})
  end

  @doc """
  GenServer callback for handling the :publish_event event.  This method
  will publish a "heartbeat" (StatuEvent) every 30 seconds

  {:noreply, state}
  """
  @spec handle_cast({:publish}, Map) :: {:noreply, Map}
  def handle_cast({:publish}, state) do
    :timer.sleep(30000)
    Logger.debug("Heartbeating...")
    publish_status_event(state)
    GenServer.cast(__MODULE__, {:publish})
    {:noreply, state}
  end

  def publish_status_event(state) do
    Publisher.publish_event(%StatusEvent{
      status: :active,
      workload: state[:workload]
    })    
  end

  @doc """
  GenServer callback for handling the :set_workflow event.  This method
  will store the current worklow into the server's state.

  {:noreply, state}
  """
  @spec handle_call({:set_workload, List}, term, Map) :: {:reply, :ok, Map}
  def handle_call({:set_workload, workload}, _from, state) do
    {:reply, :ok, Map.put(state, :workload, workload)}
  end
end