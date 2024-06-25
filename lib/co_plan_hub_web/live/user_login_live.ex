defmodule CoPlanHubWeb.UserLoginLive do
  use CoPlanHubWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-sky-600 hover:underline">
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
          <.link href={~p"/users/reset_password"} class="text-sm w-full text-right text-slate-900 hover:text-slate-700 dark:text-sky-50 dark:hover:text-sky-300">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full bg-sky-900 hover:bg-sky-700 dark:bg-sky-600 hover:dark:bg-sky-700 dark:text-sky-100 hover:dark:text-sky-200">
            Log in
          </.button>
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
