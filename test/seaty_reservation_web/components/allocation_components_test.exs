defmodule SeatyReservationWeb.AllocationComponentsTest do
  use ExUnit.Case
  alias SeatyReservationWeb.AllocationComponents

  describe "color_for_reservation/1" do
    test "reservations with same group get same color" do
      # Reservation 1: code R001, group 1
      res1 = %{code: "R001", group: 1}

      # Reservation 2: code R002, group 1 (same group as res1)
      res2 = %{code: "R002", group: 1}

      # Reservation 3: code R003, group 2 (different group)
      res3 = %{code: "R003", group: 2}

      # Reservation 4: code R004, no group
      res4 = %{code: "R004", group: nil}

      color1 = AllocationComponents.color_for_reservation(res1)
      color2 = AllocationComponents.color_for_reservation(res2)
      color3 = AllocationComponents.color_for_reservation(res3)
      color4 = AllocationComponents.color_for_reservation(res4)

      # Same group should have same color
      assert color1 == color2
      assert color2 != color3

      # Different groups should have different colors (or at least not guaranteed same)
      # We can't guarantee they're different due to hash collisions,
      # but same group MUST have same color

      # Reservation without group uses code
      assert color4 == AllocationComponents.color_for_reservation("R004")
    end

    test "4 reservations where second and third belong to same group" do
      # Reservation 1: code R001, group 1
      res1 = %{code: "R001", group: 1}

      # Reservation 2: code R002, group 2
      res2 = %{code: "R002", group: 2}

      # Reservation 3: code R003, group 2 (same as res2)
      res3 = %{code: "R003", group: 2}

      # Reservation 4: code R004, group: 3
      res4 = %{code: "R004", group: 3}

      color1 = AllocationComponents.color_for_reservation(res1)
      color2 = AllocationComponents.color_for_reservation(res2)
      color3 = AllocationComponents.color_for_reservation(res3)
      color4 = AllocationComponents.color_for_reservation(res4)

      # Reservation 2 and 3 have same group -> same color
      assert color2 == color3

      # Reservation 1 has different group -> different color
      refute color1 == color2

      # Reservation 4 has different group -> different color
      refute color2 == color4
    end

    test "group takes priority over code for color assignment" do
      # Two reservations with different codes but same group
      res1 = %{code: "R001", group: 100}
      res2 = %{code: "R002", group: 100}

      # One reservation with same code but no group
      res3 = %{code: "R001", group: nil}

      color1 = AllocationComponents.color_for_reservation(res1)
      color2 = AllocationComponents.color_for_reservation(res2)
      color3 = AllocationComponents.color_for_reservation(res3)

      # res1 and res2 have same group -> same color
      assert color1 == color2

      # res1 has group, res3 has no group but same code
      # They should have DIFFERENT colors because group takes priority
      # res1 uses "GroupX" for color, res3 uses "R001" for color
      refute color1 == color3
    end

    test "color is consistent across multiple calls" do
      res = %{code: "R123", group: 50}

      color1 = AllocationComponents.color_for_reservation(res)
      color2 = AllocationComponents.color_for_reservation(res)
      color3 = AllocationComponents.color_for_reservation(res)

      assert color1 == color2
      assert color2 == color3
    end

    test "string input works for group-only lookup" do
      # Direct integer input (for group)
      color1 = AllocationComponents.color_for_reservation(42)
      color2 = AllocationComponents.color_for_reservation(42)

      assert color1 == color2
    end
  end
end
