# ID-001: Title

## User story

As staff member, I want printable reservation cards in allocation details so I can prepare guest reservations for an event.

## Acceptance criteria

- [ ] Allocation details includes separate Reservation Cards tab (between Tickets and Resevations).
- [ ] Tab shows one card per active reservation for allocation event; cancelled reservations (`seats = 0`) are excluded.
- [ ] Each card shows reservation code, reserved-seat count, guest name, and internal comment.
- [ ] Cards use print styling like ticket page: A4 layout with three cards per row.
- [ ] Printed output contains same card data as screen view.

## Technical notes

- Reuse ticket page print styles/pattern where applicable.
- Load event reservations through existing Reservations context; no schema changes.
- Add component/controller tests for active-only cards, required fields, and tab rendering.

## Out of scope

- Generating PDF files or sending cards by email.
- Changing allocation algorithm or reservation data.
- Card editing from allocation details.

## Implementation Plan

## Status

New
