#
# == event.ex
#
# This module contains the protocol definition for Overseer Events
#
defprotocol OpenAperture.OverseerApi.Events.Event do

  @doc """

  Method to determine the type of Event

  ## Return Values

  term
  """
  @spec type(any) :: term
  def type(event)
end