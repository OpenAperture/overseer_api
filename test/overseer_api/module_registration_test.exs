defmodule OpenAperture.OverseerApi.ModuleRegistrationTest do
  use ExUnit.Case, async: false

  alias OpenAperture.OverseerApi.ModuleRegistration
  alias OpenAperture.ManagerApi.MessagingExchangeModule

  #===============================
  # register_module tests

  test "register_module - success" do 
    :meck.new(MessagingExchangeModule, [:passthrough])
    :meck.expect(MessagingExchangeModule, :create_module!, fn _, _ -> true end)

    module = %{
      hostname: System.get_env("HOSTNAME"),
      type: Application.get_env(:openaperture_overseer_api, :module_type),
      status: :active,
      workload: []      
    }
    assert ModuleRegistration.register_module(module) == true
  after
    :meck.unload(MessagingExchangeModule)
  end

  test "register_module - failure" do 
    :meck.new(MessagingExchangeModule, [:passthrough])
    :meck.expect(MessagingExchangeModule, :create_module!, fn _, _ -> false end)

    module = %{
      hostname: System.get_env("HOSTNAME"),
      type: Application.get_env(:openaperture_overseer_api, :module_type),
      status: :active,
      workload: []      
    }
    assert ModuleRegistration.register_module(module) == false
  after
    :meck.unload(MessagingExchangeModule)
  end  
end
