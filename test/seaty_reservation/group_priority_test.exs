defmodule SeatyReservation.GroupPriorityTest do
  use SeatyReservation.DataCase

  alias SeatyReservation.Reservations
  import SeatyReservation.EventsFixtures

  test "same group reservations should have same priority" do
    event = event_fixture()

    # res1: seats: 4, group: 1
    {:ok, res1} =
      Reservations.create_reservation(%{
        "event_id" => event.id,
        "name" => "Res1",
        "contact" => "res1@test.com",
        "seats" => 4,
        "group" => 1
      })

    # res2: seats: 2, group: nil
    {:ok, res2} =
      Reservations.create_reservation(%{
        "event_id" => event.id,
        "name" => "Res2",
        "contact" => "res2@test.com",
        "seats" => 2,
        "group" => nil
      })

    # res3: seats: 1, group: 1
    {:ok, res3} =
      Reservations.create_reservation(%{
        "event_id" => event.id,
        "name" => "Res3",
        "contact" => "res3@test.com",
        "seats" => 1,
        "group" => nil
      })

    {:ok, ures3} = Reservations.update_reservation(res3, %{group: 1})
    ures1 = Reservations.get_reservation_by_code(res1.code)

    assert ures1.prio == ures3.prio
    assert res2.prio > ures3.prio
    assert res2.prio > ures1.prio
  end

  test "cancellation should not change group priority" do
    event = event_fixture()

    # res1: seats: 4, group: 1
    {:ok, res1} =
      Reservations.create_reservation(%{
        "event_id" => event.id,
        "name" => "Res1",
        "contact" => "res1@test.com",
        "seats" => 4,
        "group" => 1
      })

    # res3: seats: 1, group: 1
    {:ok, res3} =
      Reservations.create_reservation(%{
        "event_id" => event.id,
        "name" => "Res3",
        "contact" => "res3@test.com",
        "seats" => 1,
        "group" => nil
      })

    {:ok, ures3} = Reservations.update_reservation(res3, %{group: 1})
    {:ok, ures1} = Reservations.update_reservation(res1, %{prio: 1000})

    uures3 = Reservations.get_reservation_by_code(ures3.code)

    assert uures3.prio == 1000

    {:ok, _} = Reservations.update_reservation(uures3, %{prio: 0, seats: 0})

    uures1 = Reservations.get_reservation_by_code(ures1.code)

    assert uures1.prio == 1000

  end
end
