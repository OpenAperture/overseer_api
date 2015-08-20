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
  @spec start_link() :: {:ok, pid} | {:error, String.t}
  def start_link() do
    Logger.debug("[Heartbeat] Starting...")

    case GenServer.start_link(__MODULE__, %{}, name: __MODULE__) do
      {:ok, pid} ->
        if Application.get_env(:openaperture_overseer_api, :autostart, true) do
          GenServer.cast(pid, {:publish})
        end

        Agent.start_link(fn -> [] end, name: HeartbeatWorkload)
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
    Agent.update(HeartbeatWorkload, fn _ -> workload end)
  end

  @doc """
  GenServer callback for handling the :publish_event event.  This method
  will publish a "heartbeat" (StatuEvent) every 30 seconds

  {:noreply, state}
  """
  @spec handle_cast({:publish}, Map) :: {:noreply, Map}
  def handle_cast({:publish}, state) do
    :timer.sleep(30000)
    Logger.debug("[Heartbeat] Heartbeat...")
    publish_status_event(state)
    GenServer.cast(__MODULE__, {:publish})
    {:noreply, state}
  end

  def publish_status_event(_state) do
    workload = Agent.get(HeartbeatWorkload, fn workload -> workload end)
    workload = if workload == nil do
      []
    else
      workload
    end

    Publisher.publish_event(%StatusEvent{
      status: :active,
      workload: workload
    })
  end
end