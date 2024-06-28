defmodule CoPlanHubWeb.ItineraryEditLive do
  use CoPlanHubWeb, :live_view

  alias CoPlanHub.Itineraries

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg">
      <.header class="text-center">
        Update itinerary
        <:subtitle>
          Update your travel planning now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="itinerary_form" phx-submit="save">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>
         <.input field={@form[:guid]} type="hidden" />
        <.input field={@form[:name]} type="text" label="Itinerary Name" required />
        <.input field={@form[:description]} type="textarea" label="Description" required />
        <div class="flex w-full gap-4">
          <.input field={@form[:start_date]} type="date" label="Start Date" required />
          <.input field={@form[:end_date]} type="date" label="End Date" />
        </div>

        <:actions>
          <.button phx-disable-with="Updating itinerary..." class="w-full btn-primary">
            Update Itinerary
          </.button>
        </:actions>
      </.simple_form>

      <.back navigate={~p"/itineraries"}>Return to List</.back>
    </div>
    """
  end

  @spec mount(any(), any(), any()) :: {:ok, map(), [{:temporary_assigns, [...]}, ...]}
  def mount(%{"guid" => guid}, _session, socket) do
    itinerary = Itineraries.get_itinerary_by_guid!(guid)
    changeset = Itineraries.change_itinerary(itinerary)

    socket =
      socket
      |> assign(check_errors: false)
      |> assign(:form, to_form(changeset, as: "itinerary"))
      |> assign(:page_title, "Update Itinerary")

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"itinerary" => itinerary_params}, socket) do
    guid = itinerary_params["guid"]
    itinerary = Itineraries.get_itinerary_by_guid!(guid)

    case Itineraries.update_itinerary(itinerary, itinerary_params) do
      {:ok, itinerary} ->
        form =
          itinerary
          |> Itineraries.change_itinerary(itinerary_params)
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Itinerary updated successfully")
         |> assign(:form, form)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign(:form, to_form(changeset, as: "itinerary"))}
    end
  end
end
