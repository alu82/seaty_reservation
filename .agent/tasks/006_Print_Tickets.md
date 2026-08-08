# ID-004: Print Tickets

## User story

As the guy who sits at the entrance, I want that the tickets are printed with all the information, to avoid missunderstandings
and to make the whole process faster.

## Acceptance criteria

- [ ] Tab with reservation cards/Tickets created on allocation details page
  - In total there will then be 2 tabs. One with the current allocation details and one with the tickets
  - The tab structure starts below the information to the allocation (created, uptodate, fullallocated)
- [ ] For each allocated seat the following information is shown
  - Name of the production
  - Date of the event
  - Reservation Code
  - Row Number
  - Seat Number

## Technical notes

- Tabs should be as lean as possible an not take use additional horizontal space
- Top left: icon priv/static/images/logo_icon.svg
- Below the production name (as title)
- below Allocation details (without explicit title, but information should be shown together and in a similar way)
  - Reservation Code
  - date of event  i.e. 06.12.2026 | 20:00
  - row and seat, i.e. Reihe 4 | Platz 14 (in german)
- on desktop create rows of 4, mobile rows of 1

## Implementation Plan

## Status

Ready
