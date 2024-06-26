defmodule CoPlanHubWeb.ItineraryComponent do
  use CoPlanHubWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="itinerary-card p-4 w-full md:w-[48%] lg:w-[31%] xl:w-[23%] 2xl:w-[18%] rounded-xl shadow-md divide-y">
      <div>
        <div class="text-xl font-bold"><%= @itinerary.name %></div>

        <p class="description"><%= @itinerary.description %></p>

        <div class="text-sm description mt-2">
          <p><strong>Travel Date</strong></p>
          <p><%= @itinerary.start_date %> - <%= @itinerary.end_date %></p>
        </div>
      </div>

      <div class="mt-2 pt-2 text-right">
        <.link navigate={~p"/itineraries/#{@itinerary.id}/edit"}>
          <.button class="w-1/5 btn-primary">
            Edit
          </.button>
        </.link>
      </div>
    </div>
    """
  end
end
