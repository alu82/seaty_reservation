defmodule SeatyReservationWeb.AllocationComponents do
  use Phoenix.Component

  @reservation_colors [
    "bg-red-100",
    "bg-blue-100",
    "bg-green-100",
    "bg-yellow-100",
    "bg-purple-100",
    "bg-pink-100",
    "bg-indigo-100",
    "bg-teal-100",
    "bg-orange-100",
    "bg-cyan-100",
    "bg-rose-100",
    "bg-emerald-100"
  ]

  def color_for_reservation(reservation) when is_map(reservation) do
    if reservation[:group] do
      color_for_reservation(reservation[:group])
    else
      color_for_reservation(reservation[:code] || reservation["code"])
    end
  end

  def color_for_reservation(group_or_code),
    do: Enum.at(@reservation_colors, rem(abs(:erlang.crc32(to_string(group_or_code))), 12))

  @doc """
  Renders a row of seats for the allocation visualization.

  ## Attributes

  * row_number - The row number to display
  * seat_count - Number of seats in this row
  * assigned - List of assigned seats for this row (maps with :row, :seat, :code, :name)
  """
  def row(assigns) do
    ~H"""
    <div class="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden mb-8">
      <div class="px-2 py-3">
        <div class="flex items-center justify-center font-semibold text-slate-800 text-center">
          Row <%= @row_number %>
          <.row_indicator row={@row_number} class="w-20 h-10" />
        </div>
      </div>
      <div class="p-1">
        <div class="grid grid-cols-2 gap-1">
          <!-- Left column: odd seats -->
          <div class="grid grid-cols-1 gap-1">
            <%= for seat <- 1..@seat_count do %>
              <%= if rem(seat, 2) == 1 do %>
                <% assigned = Enum.find(@assigned, &(&1.seat == seat)) %>
                <.seat_card seat={seat} assigned={assigned} />
              <% end %>
            <% end %>
          </div>
          <!-- Right column: even seats -->
          <div class="grid grid-cols-1 gap-1">
            <%= for seat <- 1..@seat_count do %>
              <%= if rem(seat, 2) == 0 do %>
                <% assigned = Enum.find(@assigned, &(&1.seat == seat)) %>
                <.seat_card seat={seat} assigned={assigned} />
              <% end %>
            <% end %>
            <!-- in case of uneven seats, create a dummy seat so that  the two columns are equally long -->
            <div class="invisible">
              <%= if rem(@seat_count, 2) != 0 do %>
                <.seat_card seat={@seat_count + 1} assigned={nil} />
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a seat card for the allocation visualization.

  ## Attributes

  * seat - The seat number
  * assigned - The assigned reservation for this seat (map with :code, :name) or nil
  """
  def seat_card(assigns) do
    ~H"""
    <% bg_class =
      if @assigned do
        color_for_reservation(@assigned)
      else
        "bg-slate-100"
      end

    text_align_class = if rem(@seat, 2) == 0, do: "text-left", else: "text-right" %>
    <div class={"h-24 rounded-lg border border-slate-300 py-2 px-1 shadow-sm #{bg_class} #{text_align_class}"}>
      <div class="text-xs font-semibold uppercase tracking-wide text-slate-600">
        <%= @seat %>
      </div>
      <%= if @assigned do %>
        <div class="mt-1 text-xs font-semibold text-slate-500">
          <%= @assigned.code %>
        </div>
        <div class="mt-1 text-xs text-slate-900 line-clamp-2">
          <%= @assigned.name %>
        </div>
      <% end %>
    </div>
    """
  end

  def row_indicator(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 20 10" xmlns="http://www.w3.org/2000/svg">
      <!-- upper row: 4 bars -->
      <rect x="6" y="1" width="1" height="3" fill={row_color(@row, 1)} />
      <rect x="8" y="1" width="1" height="3" fill={row_color(@row, 2)} />
      <rect x="10" y="1" width="1" height="3" fill={row_color(@row, 3)} />
      <rect x="12" y="1" width="1" height="3" fill={row_color(@row, 4)} />
      <!-- lower row: 5 bars -->
      <rect x="5" y="5" width="1" height="3" fill={row_color(@row, 5)} />
      <rect x="7" y="5" width="1" height="3" fill={row_color(@row, 6)} />
      <rect x="9" y="5" width="1" height="3" fill={row_color(@row, 7)} />
      <rect x="11" y="5" width="1" height="3" fill={row_color(@row, 8)} />
      <rect x="13" y="5" width="1" height="3" fill={row_color(@row, 9)} />
    </svg>
    """
  end

  @doc """
  Renders a ticket card for printing.

  ## Attributes

  * production_name - Name of the production
  * event_date - Date of the event (naive datetime)
  * code - Reservation code
  * row - Row number
  * seat - Seat number
  """
  def ticket_card(assigns) do
    ~H"""
    <div class="ticket-card border border-slate-300 rounded-lg p-3 bg-white shadow-sm print:border print:border-gray-400">
      <div class="flex flex-col items-center gap-2">
        <img src="/images/logo_icon.svg" alt="Logo" class="h-12 object-contain brightness-0" />
        <div class="text-center">
          <h3 class="font-bold text-lg text-slate-800"><%= @production_name %></h3>
          <div class="text-base text-slate-600 mt-1">
            <%= format_date(@event_date) %> | <%= format_time(@event_date) %>
          </div>
          <div class="mt-2">
            <div class="text-base font-medium text-slate-600">
              <%= @code %>
            </div>
            <div class="text-base text-slate-600">
              Reihe <%= @row %> | Platz <%= @seat %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp row_color(current_row, row) do
    if current_row == row, do: "#2563eb", else: "#cbd5e1"
  end

  @weekday_abbrs ["MO", "DI", "MI", "DO", "FR", "SA", "SO"]

  defp format_date(%NaiveDateTime{year: year, month: month, day: day}) do
    dt = Date.new!(year, month, day)
    wday = Date.day_of_week(dt) - 1
    "#{Enum.at(@weekday_abbrs, wday)} | #{pad(day)}.#{pad(month)}.#{year}"
  end
  defp format_date(_), do: ""

  defp format_time(%NaiveDateTime{hour: hour, minute: minute}), do: "#{pad(hour)}:#{pad(minute)}"
  defp format_time(_), do: ""

  defp pad(n), do: String.pad_leading(to_string(n), 2, "0")

  @doc """
  Renders a reservations table for the allocation details page.

  ## Attributes

  * assigned - List of assigned seats (maps with :code, :name, :seats, :row, :seat)
  """
  def reservations_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reservation Code</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Seats</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for {display_name, code, count} <- @assigned
               |> Enum.group_by(fn e -> {e.name, e.code} end)
               |> Enum.flat_map(fn { {name, code}, entries} ->
                 name_parts = String.split(name) |> Enum.filter(&(String.length(&1) > 3))
                 [{name, code, length(entries)} | Enum.map(name_parts, &{&1, code, length(entries)})]
               end)
               |> Enum.sort_by(fn {name, _code, _count} -> name end) do %>
            <tr>
              <td class="px-6 py-2 whitespace-nowrap text-sm text-gray-900"><%= display_name %></td>
              <td class="px-6 py-2 whitespace-nowrap text-sm text-gray-900"><%= code %></td>
              <td class="px-6 py-2 whitespace-nowrap text-sm text-gray-900"><%= count %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
