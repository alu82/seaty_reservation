defmodule SeatyReservationWeb.AllocationComponents do
  use Phoenix.Component

  @doc """
  Renders a row of seats for the allocation visualization.

  ## Attributes

  * row_number - The row number to display
  * seat_count - Number of seats in this row
  * assigned - List of assigned seats for this row (maps with :row, :seat, :code, :name)
  """
  def row(assigns) do
    ~H"""
    <div class="rounded-xl border border-slate-200 bg-slate-200 shadow-sm overflow-hidden">
      <div class="border-b px-4 py-3">
        <div class="font-semibold text-slate-800 text-center">
          Row <%= @row_number %>
        </div>
      </div>
      <div class="p-4">
        <div class="grid grid-cols-2 gap-3">
          <!-- Left column: odd seats -->
          <div class="grid grid-cols-1 gap-2">
            <%= for seat <- 1..@seat_count do %>
              <%= if rem(seat, 2) == 1 do %>
                <% assigned = Enum.find(@assigned, &(&1.seat == seat)) %>
                <.seat_card seat={seat} assigned={assigned} />
              <% end %>
            <% end %>
          </div>
          <!-- Right column: even seats -->
          <div class="grid grid-cols-1 gap-2">
            <%= for seat <- 1..@seat_count do %>
              <%= if rem(seat, 2) == 0 do %>
                <% assigned = Enum.find(@assigned, &(&1.seat == seat)) %>
                <.seat_card seat={seat} assigned={assigned} />
              <% end %>
            <% end %>
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
    <div class={"rounded-lg border border-slate-300 p-2 shadow-sm transition hover:shadow-md hover:border-slate-400 " <> if @assigned, do: "bg-white", else: "bg-slate-100"}>
      <div class={"text-xs font-semibold uppercase tracking-wide " <> if @assigned, do: "text-slate-500", else: "text-slate-400"}>
        Seat <%= @seat %>
      </div>
      <%= if @assigned do %>
        <div class="mt-1 text-xs font-mono text-slate-600">
          <%= @assigned.code %>
        </div>
        <div class="mt-1 text-xs font-semibold text-slate-900 truncate">
          <%= @assigned.name %>
        </div>
      <% end %>
    </div>
    """
  end
end
