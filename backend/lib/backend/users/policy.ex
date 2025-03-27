defmodule Backend.Users.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:create_user, _user, _params), do: true
  def authorize(:update_user, user, %{user: target_user} = _params), do: user.id == target_user.id
end
