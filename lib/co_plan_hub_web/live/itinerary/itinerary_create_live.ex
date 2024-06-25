defmodule CoPlanHubWeb.ItineraryCreateLive do
  use CoPlanHubWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg">
      <.header class="text-center">
        Create an itinerary
        <:subtitle>
          Start your travel planning now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="itinerary_form"
        phx-submit="save"
        phx-trigger-action={@trigger_submit}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:name]} type="text" label="Itinerary Name" required />
        <.input field={@form[:description]} type="textarea" label="Description" required />
        <.input field={@form[:start_date]} type="date" label="Start Date" required />
        <.input field={@form[:end_date]} type="date" label="Start Date" required />
      </.simple_form>
    </div>
    """
  end
end
