defmodule OpenAperture.OverseerApi.RequestTest do
  use ExUnit.Case

  alias OpenAperture.OverseerApi.Request

  test "from_payload" do
    payload = %{
      action: :upgrade_request,
      options: %{force: true}
    }

    request = Request.from_payload(payload)
    assert request != nil
    assert request.upgrade_request == :upgrade_request
    assert requst.options[:force] == true
  end

  test "to_payload" do
    request = %Request{
      action: :upgrade_request,
      options: %{force: true},
    }

    payload = Request.to_payload(request)
    assert payload != nil
    assert request.action == payload[:upgrade_request]
    assert request.options == payload[:options]
  end  
end