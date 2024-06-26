defmodule CoPlanHubWeb.ItineraryListLive do
  use CoPlanHubWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg">
      <.header class="text-center">
        My Itineraries
        <:actions>
          <.link navigate={~p"/itineraries/new"}>
            <.button class="w-full btn-primary">
              New Itinerary
            </.button>
          </.link>
        </:actions>
      </.header>
    </div>
    """
  end
end
