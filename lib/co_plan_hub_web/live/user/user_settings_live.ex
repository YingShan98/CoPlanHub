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
          <.simple_form
            for={@profile_form}
            id="profile_form"
            phx-submit="update_profile"
            phx-change="validate_profile"
          >
            <.error :if={@profile_form.errors != []}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <.error :if={upload_errors(@uploads.profile_image) != []}>
              <%= for err <- upload_errors(@uploads.profile_image) do %>
                <%= error_to_string(err) %>
              <% end %>
            </.error>

            <div class="flex justify-between items-center gap-4 w-full">
              <figure class="w-1/2 flex justify-center">
                <%= if @uploads.profile_image.entries |> Enum.count() > 0 do %>
                  <%= for entry <- @uploads.profile_image.entries do %>
                    <.live_img_preview entry={entry} width="75" height="75" class="rounded-full" />
                  <% end %>
                <% else %>
                  <%= if @profile_image_url do %>
                    <img
                      src={"data:image/png;base64," <> Base.encode64(@profile_image_url)}
                      width="75"
                      height="75"
                      class="rounded-full"
                    />
                  <% else %>
                    <img
                      src={~p"/images/default-user-image.svg"}
                      width="75"
                      height="75"
                      class="rounded-full"
                    />
                  <% end %>
                <% end %>
              </figure>

              <div class="w-1/2 flex justify-start">
                <.label
                  for={@uploads.profile_image.ref}
                  class="rounded-lg py-2 px-3 btn-primary cursor-pointer"
                >
                  Upload
                </.label>
                 <.live_file_input upload={@uploads.profile_image} class="hidden" />
              </div>
            </div>

            <div class="flex gap-2 justify-between">
              <.input field={@profile_form[:first_name]} type="text" label="First Name" required />
              <.input field={@profile_form[:last_name]} type="text" label="Last Name" required />
            </div>
             <.input field={@profile_form[:username]} type="text" label="Username" required />
            <div class="flex gap-2 justify-between">
              <.input field={@profile_form[:email]} type="email" label="Email" disabled />
              <.link phx-click={show_modal("update-email-modal")} class="mt-8 align-middle">
                <.button class="btn-primary py-3">
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
      |> assign(:uploaded_files, [])
      |> assign(:profile_image_url, if(user.image, do: user.image.bytes))
      |> allow_upload(:profile_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1
      )
      |> assign(:page_title, "User Profile")

    {:ok, socket}
  end

  def handle_event("validate_profile", %{"user" => user_params}, socket) do
    profile_form =
      socket.assigns.current_user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :profile_image, fn %{path: path}, entry ->
        # Read the file content as binary
        {:ok, file_content} = File.read(path)

        {:ok, %{filename: entry.client_name, file_content: file_content}}
      end)

    image_params =
      case uploaded_files do
        [%{filename: filename, file_content: profile_image_content} | _] ->
          %{
            filename: filename,
            description: "User #{user_params["username"]}'s profile image",
            bytes: profile_image_content
          }

        _ ->
          # Default or no image params
          %{}
      end

    # Create or update image changeset
    image_changeset =
      if user.image do
        CoPlanHub.Attachments.Image.changeset(user.image, image_params)
      else
        CoPlanHub.Attachments.Image.changeset(%CoPlanHub.Attachments.Image{}, image_params)
      end

    case CoPlanHub.Repo.insert_or_update(image_changeset) do
      {:ok, image} ->
        user_params = Map.put(user_params, "image_id", image.id)

        case Accounts.update_user_profile(user, user_params) do
          {:ok, updated_user} ->
            # Reload the updated user with associated image data
            updated_user_with_image = Accounts.get_user!(updated_user.id)

            profile_form =
              updated_user_with_image
              |> Accounts.change_user_profile(user_params)
              |> to_form()

            {:noreply,
             socket
             |> put_flash(:info, "User Profile updated successfully")
             |> assign(:profile_form, profile_form)
             |> assign(:uploaded_files, uploaded_files)
             |> assign(
               :profile_image_url,
               if(updated_user_with_image.image, do: updated_user_with_image.image.bytes)
             )}

          {:error, changeset} ->
            {:noreply, assign(socket, profile_form: to_form(changeset))}
        end

      {:error, _changeset} ->
        {:noreply, socket}
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
