defmodule Backend.Users.Policy do
  @behaviour Bodyguard.Policy

  def authorize(:update_user, _user, %{session_role: session_role}) do
    session_role == :student or session_role == :instructor
  end
end
