defmodule CoPlanHubWeb.UserRegistrationLive do
  use CoPlanHubWeb, :live_view

  alias CoPlanHub.Accounts
  alias CoPlanHub.Accounts.User
  alias CoPlanHub.Attachments.Image

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
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

        <div class="flex gap-4 justify-between">
          <.input field={@form[:first_name]} type="text" label="First Name" required />
          <.input field={@form[:last_name]} type="text" label="Last Name" required />
        </div>
         <.input field={@form[:username]} type="text" label="Username" required />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Password Confirmation"
          required
        />
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full btn-primary">
            Create an account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:uploaded_files, [])
      |> assign(:profile_image_url, nil)
      |> allow_upload(:profile_image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1
      )
      |> assign_form(changeset)
      |> assign(:page_title, "User Registration")

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :profile_image, fn %{path: path}, entry ->
        # Read the file content as binary
        {:ok, file_content} = File.read(path)

        {:ok, %{filename: entry.client_name, file_content: file_content}}
      end)

    # Insert the uploaded image into the images table
    image_id =
      case uploaded_files do
        [%{filename: filename, file_content: profile_image_content} | _] ->
          # Create a changeset for the image
          image_changeset =
            Image.changeset(%Image{}, %{
              filename: filename,
              description: "User #{user_params["username"]}'s profile image",
              bytes: profile_image_content
            })

          # Insert the image and get the image ID
          case CoPlanHub.Repo.insert(image_changeset) do
            {:ok, image} -> image.id
            {:error, _changeset} -> nil
          end

        _ ->
          nil
      end

    user_params =
      if image_id do
        Map.put(user_params, "image_id", image_id)
      else
        user_params
      end

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        # Reload the updated user with associated image data
        created_user_with_image = Accounts.get_user!(user.id)
        changeset = Accounts.change_user_registration(created_user_with_image)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign(:uploaded_files, &(&1 ++ uploaded_files))
         |> assign(
           :profile_image_url,
           if(created_user_with_image.image, do: created_user_with_image.image.bytes)
         )
         |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
