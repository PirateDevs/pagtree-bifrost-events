defmodule Bifrost.Event.GoalRewarded do
  @moduledoc ~S"""
  An event emitted when the reward for an achieved goal is granted.
  """

  use Bifrost.Event.Notation

  defevent currency: Zc.currency(),
           amount: Zc.money(:cents)
end
