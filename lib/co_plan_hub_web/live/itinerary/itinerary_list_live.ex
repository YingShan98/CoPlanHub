defmodule CoPlanHubWeb.ItineraryListLive do
  use CoPlanHubWeb, :live_view
  alias CoPlanHub.Itineraries

  def render(assigns) do
    ~H"""
    <div class="mx-auto">
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

      <div class="flex flex-wrap gap-6 justify-start p-4">
        <%= for itinerary <- @itineraries do %>
          <.live_component
            module={CoPlanHubWeb.ItineraryComponent}
            id={itinerary.id}
            itinerary={itinerary}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @spec mount(any(), any(), any()) :: {:ok, map(), [{:temporary_assigns, [...]}, ...]}
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    itineraries = Itineraries.get_itineraries_by_user(current_user.id)

    socket =
      socket
      |> assign(itineraries: itineraries)
      |> assign(:page_title, "Itineraries")

    {:ok, socket, temporary_assigns: [itineraries: []]}
  end
end
