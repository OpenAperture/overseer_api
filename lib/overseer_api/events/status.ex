#
# == status.ex
#
# This module contains the implementation for Overseer Status events
#
defmodule OpenAperture.OverseerApi.Events.Status do

  @type t :: %__MODULE__{}
  defstruct status: :active, workload: []

  defimpl OpenAperture.OverseerApi.Events.Event, for: OpenAperture.OverseerApi.Events.Status do
    @doc """

    Method to determine the type of Event (implementation)

    ## Return Values

    :status
    """
    @spec type(any) :: :status
    def type(_), do: :status
  end
end
