defmodule Backend.Users.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:update_user, user, %{user: target_user} = _params), do: user.id == target_user.id
end
