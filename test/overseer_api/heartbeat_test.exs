defmodule OpenAperture.OverseerApi.HeartbeatTest do
  use ExUnit.Case, async: false

  alias OpenAperture.OverseerApi.Heartbeat
  alias OpenAperture.OverseerApi.Publisher

  #===============================
  # publish_status_event tests

  test "publish_status_event - success" do 
    :meck.new(Publisher, [:passthrough])
    :meck.expect(Publisher, :publish_event, fn _ -> :ok end)

    module = %{
      hostname: System.get_env("HOSTNAME"),
      type: Application.get_env(:openaperture_overseer_api, :module_type),
      status: :active,
      workload: []      
    }
    assert Heartbeat.publish_status_event(%{}) == :ok
  after
    :meck.unload(Publisher)
  end 
end
