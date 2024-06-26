defmodule CoPlanHubWeb.UserLoginLive do
  use CoPlanHubWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm w-full text-right">
            Forgot your password?
          </.link>
        </:actions>

        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full btn-primary">
            Log in
          </.button>
        </:actions>

        <:actions>
          <.link
            href={~p"/users/confirm"}
            class="text-sm w-full text-right"
          >
            Resend activation instruction
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    socket =
      socket
      |> assign(:page_title, "Login")

    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
