defmodule Chatter.Accounts do
  alias Chatter.{Repo, User}
  alias Doorman.Auth.Secret

  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Secret.put_session_secret()
    |> Repo.insert()
  end

  def change_user(user) do
    User.changeset(user, %{})
  end
end
