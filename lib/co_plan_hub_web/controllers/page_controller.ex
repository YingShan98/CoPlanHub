defmodule CoPlanHubWeb.PageController do
  use CoPlanHubWeb, :controller

  alias CoPlanHub.Itineraries
  alias CoPlanHub.Itineraries.Itinerary

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    changeset = Itineraries.change_itinerary(%Itinerary{})

    render(conn, :home, layout: false, form: changeset, page_title: "Home")
  end
end
