defmodule CoPlanHubWeb.ItineraryCreateLive do
  alias CoPlanHub.Itineraries
  alias CoPlanHub.Itineraries.Itinerary
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

      <.simple_form for={@form} id="itinerary_form" phx-submit="save">
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>
         <.input field={@form[:name]} type="text" label="Itinerary Name" required />
        <.input field={@form[:description]} type="textarea" label="Description" required />
        <.date_range_picker
          label="Travel Date Range"
          id="travel_date_range_picker"
          form={@form}
          start_date_field={@form[:start_date]}
          end_date_field={@form[:end_date]}
          required={true}
        />
        <:actions>
          <.button phx-disable-with="Creating itinerary..." class="w-full btn-primary">
            Create Itinerary
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @spec mount(any(), any(), any()) :: {:ok, map(), [{:temporary_assigns, [...]}, ...]}
  def mount(_params, _session, socket) do
    changeset = Itineraries.change_itinerary(%Itinerary{})

    socket =
      socket
      |> assign(check_errors: false)
      |> assign_form(changeset)
      |> assign(:page_title, "Create Itinerary")

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"itinerary" => itinerary_params}, socket) do
    user = socket.assigns.current_user

    case Itineraries.create_itinerary(itinerary_params, user) do
      {:ok, itinerary} ->
        changeset = Itineraries.change_itinerary(itinerary)
        {:noreply, socket |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "itinerary")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
