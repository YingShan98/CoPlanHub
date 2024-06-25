defmodule CoPlanHubWeb.UserSettingsLive do
  use CoPlanHubWeb, :live_view

  alias CoPlanHub.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md">
      <.header class="text-center">
        User Profile
        <:subtitle>Manage your account information</:subtitle>
      </.header>

      <div class="space-y-12 divide-y">
        <div>
          <.simple_form for={@profile_form} id="profile_form" phx-submit="update_profile">
            <.error :if={@profile_form.errors != []}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <div class="flex gap-2 justify-between">
              <.input field={@profile_form[:first_name]} type="text" label="First Name" required />
              <.input field={@profile_form[:last_name]} type="text" label="Last Name" required />
            </div>
             <.input field={@profile_form[:username]} type="text" label="Username" required />
            <div class="flex gap-2 justify-between">
              <.input field={@profile_form[:email]} type="email" label="Email" disabled />
              <.link phx-click={show_modal("update-email-modal")} class="mt-8 align-middle">
                <.button class="btn py-3 bg-sky-900 hover:bg-sky-700 dark:bg-sky-600 hover:dark:bg-sky-700 dark:text-sky-100 hover:dark:text-sky-200">
                  <FontAwesome.pen class="h-4 w-4" />
                </.button>
              </.link>
            </div>

            <:actions>
              <.button phx-disable-with="Updating..." class="btn-primary">
                Update Profile
              </.button>

              <.link phx-click={show_modal("update-password-modal")}>
                <.button class="btn-primary">
                  Reset Password
                </.button>
              </.link>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>

    <.modal id="update-email-modal">
      <:header>Update Email</:header>

      <.simple_form for={@email_form} id="email_form" phx-submit="update_email">
        <.error :if={@email_form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@email_form[:email]}
          id="new_email_for_user"
          type="email"
          label="Email"
          required
        />
        <.input
          field={@email_form[:current_password]}
          name="current_password"
          id="current_password_for_email"
          type="password"
          label="Current password"
          value={@email_form_current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing..." class="btn-primary">
            Change Email
          </.button>
        </:actions>
      </.simple_form>
    </.modal>

    <.modal id="update-password-modal">
      <:header>Update Password</:header>

      <.simple_form
        for={@password_form}
        id="password_form"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <.error :if={@password_form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        /> <.input field={@password_form[:password]} type="password" label="New password" required />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
        />
        <.input
          field={@password_form[:current_password]}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing..." class="btn-primary">
            Change Password
          </.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    profile_changeset = Accounts.change_user_profile(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:page_title, "User Profile")

    {:ok, socket}
  end

  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params

    profile_form =
      socket.assigns.current_user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, user} ->
        profile_form =
          user
          |> Accounts.change_user_profile(user_params)
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "User Profile updated successfully")
         |> assign(:profile_form, profile_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, profile_form: to_form(changeset))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."

        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(email_form_current_password: nil)
         |> push_event("close_modal", %{to: "#close_modal_btn_update-email-modal"})}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully")
         |> assign(:trigger_submit, true)
         |> assign(:password_form, password_form)
         |> push_event("close_modal", %{to: "#close_modal_btn_update-password-modal"})}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
