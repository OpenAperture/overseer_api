defmodule OpenAperture.OverseerApi.Request do


  @moduledoc """
  Methods and Request struct for OverseerApi requests
  """

  defstruct action: nil,
            options: nil

  @type t :: %__MODULE__{}

  @doc """
  Method to convert a map into a Request struct

  ## Options

  The `payload` option defines the Map containing the request

  ## Return Values

  OpenAperture.OverseerApi.Request.t
  """
  @spec from_payload(Map) :: OpenAperture.OverseerApi.Request.t
  def from_payload(payload) do
    %OpenAperture.OverseerApi.Request{
      action: payload[:action],
      options: payload[:options]
    }
  end

  @spec to_payload(OpenAperture.OverseerApi.Request.t) :: Map
  def to_payload(request) do
    Map.from_struct(request)
  end
end