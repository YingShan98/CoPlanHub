defmodule CoPlanHubWeb.UserConfirmationInstructionsLive do
  use CoPlanHubWeb, :live_view

  alias CoPlanHub.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        No activation instructions received?
        <:subtitle>We'll send a new activation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full btn-primary">
            Resend activation instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center text-sm mt-4 subtitle">
        <.link href={~p"/users/register"} class="hover:underline">Register</.link>
        | <.link href={~p"/users/log_in"} class="hover:underline">Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "User Activation Instruction")

    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been activated yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
