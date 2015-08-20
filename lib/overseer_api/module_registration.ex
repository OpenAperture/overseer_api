require Logger

defmodule OpenAperture.OverseerApi.ModuleRegistration do
	use GenServer

  @moduledoc """
  This module contains the GenServer for a system module to interact with the Overseer system module
  """

  alias OpenAperture.ManagerApi.MessagingExchangeModule

  @doc """
  Specific start_link implementation

  ## Return Values

  {:ok, pid} | {:error, reason}
  """
  @spec start_link() :: {:ok, pid} | {:error, String.t()}
  def start_link() do
    module = %{
    	hostname: System.get_env("HOSTNAME"),
    	type: Application.get_env(:openaperture_overseer_api, :module_type),
      status: :active,
      workload: []
    }

    case Agent.start_link(fn ->module end, name: __MODULE__) do
      {:ok, pid} ->
        if Application.get_env(:openaperture_overseer_api, :autostart, true) do
          case register_module(module) do
            true -> {:ok, pid}
            false -> {:error, "[ModuleRegistration] Failed to register module #{module[:hostname]}!"}
          end
        else
          {:ok, pid}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Method to register a system module with the Manager

  ## Return Values

  boolean
  """
  @spec register_module(Map) :: term
  def register_module(module) do
    Logger.debug("[ModuleRegistration] Registering module #{module[:hostname]} (#{module[:type]}) with OpenAperture...")
    case MessagingExchangeModule.create_module!(Application.get_env(:openaperture_overseer_api, :exchange_id), module) do
      nil ->
        response = MessagingExchangeModule.create_module(Application.get_env(:openaperture_overseer_api, :exchange_id), module)
        if response.success? do
          Logger.debug("[ModuleRegistration] Successfully registered module #{module[:hostname]}")
          true
        else
          Logger.error("[ModuleRegistration] Failed to registered module #{module[:hostname]}!  module - #{inspect module}, status - #{inspect response.status}, errors - #{inspect response.raw_body}")
          false
        end
      location ->
        Logger.debug("[ModuleRegistration] Successfully registered module #{module[:hostname]} (#{inspect location})")
        true
    end
  end

  @doc """
  Method to rretrieve the current module

  ## Return Values

  Map
  """
  @spec get_module :: Map
  def get_module do
    Agent.get(__MODULE__, fn module -> module end)
  end
end