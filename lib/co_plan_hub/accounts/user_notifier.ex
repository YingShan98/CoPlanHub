defmodule CoPlanHub.Accounts.UserNotifier do
  import Swoosh.Email
  import Phoenix.Component

  alias CoPlanHub.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, template) do
    html = heex_to_html(template)
    text = html_to_text(html)

    email =
      new()
      |> to(recipient)
      |> from({"CoPlanHub", "viviantanyingshan@gmail.com"})
      |> subject(subject)
      |> html_body(html)
      |> text_body(text)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp email_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          .container {
            background-color: rgb(243 244 246);
            border-radius: 0.25rem;
            padding: 2.5rem;
            text-align: center;
          }
        </style>
      </head>

      <body>
        <div class="container mt-10 bg-gray-100 rounded p-10 text-center">
          <%= render_slot(@inner_block) %>
        </div>
      </body>
    </html>
    """
  end

  @spec deliver_confirmation_instructions(
          atom()
          | %{
              :user => atom() | %{:email => any(), optional(any()) => any()},
              optional(any()) => any()
            }
        ) :: {:error, any()} | {:ok, Swoosh.Email.t()}
  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(assigns) do
    template = ~H"""
    <.email_layout>
      <h1 class="text-3xl font-bold mb-4">CoPlanHub</h1>

      <p>Hi <%= @user.username %>,</p>

      <p>
        Welcome to the CoPlanHub!
        You can activate your account by visiting the URL below:
      </p>
       <.link navigate={@url} target="_blank">Activate</.link>

       <p class="text-sm">If you didn't create an account with us, please ignore this.</p>
    </.email_layout>
    """

    deliver({assigns.user.name, assigns.user.email}, "Activation instructions", template)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(assigns) do
    template = ~H"""
    <.email_layout>
      <h1 class="text-3xl font-bold mb-4">CoPlanHub</h1>

      <p>Hi <%= @user.username %>,</p>

      <p>
      You can reset your password by visiting the URL below:
      </p>
       <.link navigate={@url} target="_blank">Reset Password</.link>

       <p>This link will expire in two hours.</p>

       <p class="text-sm">If you didn't request this change, please ignore this.</p>
    </.email_layout>
    """

    deliver({assigns.user.name, assigns.user.email}, "Reset password instructions", template)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(assigns) do
    template = ~H"""
    <.email_layout>
      <h1 class="text-3xl font-bold mb-4">CoPlanHub</h1>

      <p>Hi <%= @user.username %>,</p>

      <p>
      You can change your email by visiting the URL below:
      </p>
       <.link navigate={@url} target="_blank">Change Email</.link>

       <p>This link will expire in two hours.</p>

       <p class="text-sm"> If you didn't request this change, please ignore this.</p>
    </.email_layout>
    """

    deliver({assigns.user.name, assigns.user.email}, "Update email instructions", template)
  end

  defp heex_to_html(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp html_to_text(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.text(sep: "\n\n")
  end
end
