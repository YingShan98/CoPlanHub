defmodule CoPlanHubWeb.UserSessionController do
  use CoPlanHubWeb, :controller

  alias CoPlanHub.Accounts
  alias CoPlanHubWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(
      conn,
      params,
      "Account created successfully! Please check your email to activate your account."
    )
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params} = params, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      if user.confirmed_at do
        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)
      else
        case Map.get(params, "_action") do
          "registered" ->
            conn
            |> put_flash(:info, info)
            |> redirect(to: "/users/log_in")

          "password_updated" ->
            conn
            |> put_flash(:info, info)
            |> UserAuth.log_out_user()
            |> redirect(to: "/users/log_in")

          _ ->
            message = "Account not activated. Check your email for the activation link."

            conn
            |> put_flash(:error, message)
            |> redirect(to: "/")
        end

        message =
          "Account not activated. " <>
            "Check your email for the activation link."

        conn
        |> put_flash(:error, message)
        |> redirect(to: ~p"/")
      end
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
