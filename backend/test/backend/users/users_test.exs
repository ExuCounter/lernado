defmodule Backend.Users.UsersTest do
  use Backend.DataCase, async: true

  describe "users" do
    test "create user", ctx do
      ctx = ctx |> produce(:user)
    end
  end
end
