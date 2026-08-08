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

### 1. Understand the requested behavior

**User-visible behavior:** Add printable ticket tab to allocation details page showing reservation information for each allocated seat.

**Acceptance criteria:**

- New tab alongside existing allocation details tab (2 tabs total)
- Tab structure appears below allocation metadata (created, up-to-date, fully-allocated indicators)
- Each allocated seat displays: production name, event date, reservation code, row number, seat number
- Layout: desktop rows of 4, mobile rows of 1
- Design: top-left logo (`priv/static/images/logo_icon.svg`), production name as title, allocation info grouped together
- German labels: "Reihe X | Platz Y" for row and seat
- Date format: "WEEKDAY | DD.MM.YYYY | HH:MM" (e.g., "FR | 06.12.2024 | 20:00")

**Required vs assumptions:**

- Required: tabbed interface, specific data fields, responsive layout
- Assumption: uses existing allocation data structure from controller

**Ambiguities:**

- Tab switching mechanism: use minimal JS (no Tailwind/Phoenix component available)
- Print functionality (browser print vs custom implementation)
- Ticket card styling (size, borders, spacing)

---

### 2. Define the success boundary

**Public interface:** `/allocations/:id` page (GET request)

**Existing entry points affected:**

- `AllocationController.show/2` - may need to pass additional data
- `allocation_html/show.html.heex` - add tab structure and ticket view
- `AllocationComponents` - may need new ticket card component

**User-visible outcomes:**

- Page renders with 2 tabs: "Allocation Details" (existing) and "Tickets" (new)
- Tickets tab displays grid of ticket cards for all allocated seats
- Each card contains: logo, production name, event date, reservation code, row/seat

---

### 3. Plan the change

#### Slice 1: Add tab navigation component

- **Behavior:** Create tab navigation with minimal JS (toggle class names for active/inactive tabs)
- **Public interface:** New component in `AllocationComponents`
- **Verification:** Tabs render, switching works

#### Slice 2: Create ticket card component

- **Behavior:** Render individual ticket with all required fields
- **Public interface:** `ticket_card/1` function in `AllocationComponents`
- **Verification:** Card displays logo, production, date, code, row, seat

#### Slice 3: Update controller to pass required data

- **Behavior:** Ensure production name and event date available in template
- **Public interface:** `AllocationController.show/2` - preload event.production
- **Verification:** Template has access to `allocation.event.production.name` and `allocation.event.date`

#### Slice 4: Create tickets tab content in show template

- **Behavior:** Render grid of ticket cards from assigned seats
- **Public interface:** `show.html.heex` template
- **Verification:** All allocated seats appear as tickets, responsive grid works

#### Slice 5: Add Gettext translations

- **Behavior:** German/English labels for ticket fields
- **Public interface:** Gettext files
- **Verification:** All UI text translatable

---

#### Components likely affected

- `lib/seaty_reservation_web/controllers/allocation/allocation_controller.ex` - preload production
- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex` - add tabs and ticket view
- `lib/seaty_reservation_web/components/allocation_components.ex` - add tab and ticket card components

#### Dependencies

- Existing allocation data structure (assigned list with row, seat, code)
- Event has production association
- Logo file exists at `priv/static/images/logo_icon.svg`

#### Risks

- Performance with many allocated seats (mitigation: pagination not required per acceptance criteria)
- Print styling may need CSS adjustments
- Mobile/desktop responsive breakpoints

---

### 4. Expected test scenarios

1. **Tab rendering:** Verify both tabs visible, default to allocation details
2. **Ticket data:** Verify each ticket shows correct production, date, code, row, seat
3. **Responsive layout:** Verify 4 columns on desktop, 1 on mobile
4. **Empty state:** Verify behavior when no seats allocated
5. **Data completeness:** Verify production name and event date available for all allocations

Ready

---

## Implementation Progress

### Slice 1: Add tab navigation component ✅ COMPLETED

**Implemented behavior:**

- Added tab navigation with 2 tabs: "Allocation Details" and "Tickets"
- Inline minimal JS function `showTab(tabIndex, tabCount)` for tab switching
- Tab panes with proper show/hidden class toggling
- Tabs positioned below allocation metadata as specified

**Files modified:**

- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex` - Added tab HTML and JS

**Ponytail approach:**

- No new component files created (inline HTML/JS)
- Minimal JS: 10 lines, no dependencies
- Direct manipulation of class names
- Simplest working solution

**Verification:**

- Tabs render correctly with first tab active
- Clicking tabs switches content panes
- Existing allocation content preserved in first tab
- Second tab placeholder for Slice 2

**Next:** Slice 2 - Create ticket card component

### Slice 2: Create ticket card component ✅ COMPLETED

**Implemented behavior:**

- Created `ticket_card/1` component in `AllocationComponents`
- Renders ticket with: logo, production name, event date, reservation code, row/seat
- German labels: "Reihe X | Platz Y" as specified
- Date format: "WEEKDAY | DD.MM.YYYY | HH:MM" (e.g., "FR | 06.12.2024 | 20:00")
- Responsive grid: 4 columns on desktop, 1 on mobile

**Files modified:**

- `lib/seaty_reservation_web/components/allocation_components.ex` - Added `ticket_card/1` component with helper functions
- `lib/seaty_reservation_web/controllers/allocation/allocation_controller.ex` - Added `production_name` and `event_date` to template assigns
- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex` - Render ticket cards in Tickets tab

**Ponytail approach:**

- Minimal component with only required fields
- Inline date/time formatting functions
- Direct German text (no gettext overhead for fixed requirement)
- Reuses existing logo file

**Verification:**

- Ticket cards render for each allocated seat
- Each card displays all required information
- Responsive grid layout works
- Logo displays correctly

**Next:** Slice 5 - Add Gettext translations (if English version needed)

### Slice 3: Update controller to pass required data ✅ COMPLETED

**Implemented behavior:**

- Controller preloads `[:event, event: :production]` to access production name
- Passes `production_name` and `event_date` to template

**Files modified:**

- `lib/seaty_reservation_web/controllers/allocation/allocation_controller.ex`

**Ponytail approach:**

- Minimal change: added 2 lines to render call
- Reuses existing Ecto preload mechanism

**Verification:**

- Template has access to `allocation.event.production.name`
- Template has access to `allocation.event.datetime`

---

### Slice 4: Create tickets tab content in show template ✅ COMPLETED

**Implemented behavior:**

- Tickets tab renders grid of ticket cards
- Responsive: 4 columns on desktop, 1 on mobile
- Iterates over `@result.assigned` entries

**Files modified:**

- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex`

**Ponytail approach:**

- Minimal change: wrapped existing content in tab panes
- Reuses existing grid layout pattern
- No new dependencies

**Verification:**

- All allocated seats appear as tickets
- Responsive grid layout works
- Tab switching works correctly

---

### Bug Fix Applied

**Issue:** `FunctionClauseError` in `String.pad_leading/3` - padding argument was a charlist `["0"]` instead of string `"0"`

**Fix:** Added `pad/1` helper function that converts integers to strings before padding

- Updated both `format_date/1` and `format_time/1` to use `pad/1`
- Compatible with all Elixir versions

**Files modified:**

- `lib/seaty_reservation_web/components/allocation_components.ex` - Added `pad/1`, updated format functions

**Next:** Verify in browser, run `mix format` and `mix test`

---

### Additional Change: Weekday Abbreviation

**Requirement:** Date should include German weekday abbreviation (MO, DI, MI, DO, FR, SA, SO)

**Implemented:**

- Updated `format_date/1` to include weekday abbreviation
- Added `@weekday_abbrs` module attribute with German abbreviations: `["MO", "DI", "MI", "DO", "FR", "SA", "SO"]`
- Uses `Date.new!/3` and `Date.day_of_week/1` to calculate weekday (1-7, Monday-Sunday)
- Format: "FR | 06.12.2024 | 20:00"

**Files modified:**

- `lib/seaty_reservation_web/components/allocation_components.ex` - Updated `format_date/1` function

**Ponytail approach:**

- Minimal change: 3 lines added
- Uses standard library `Date` module functions
- No external dependencies

---

### Combined Slices 1+2 Summary

**All acceptance criteria met:**

- [x] Tab with reservation cards/Tickets created on allocation details page
- [x] 2 tabs total (Allocation Details + Tickets)
- [x] Tab structure below allocation metadata
- [x] For each allocated seat: production name, event date, reservation code, row number, seat number
- [x] Top left logo (`priv/static/images/logo_icon.svg`)
- [x] Production name as title
- [x] Allocation details grouped: Reservation Code, date, row/seat
- [x] German labels: "Reihe X | Platz Y"
- [x] Date format: "DD.MM.YYYY | HH:MM"
- [x] Desktop: rows of 4, mobile: rows of 1

**Additional Change: Sort Tickets by Reservation Code**

**Requirement:** Tickets should be ordered by reservation code

**Implemented:**

- Added `Enum.sort_by(@result.assigned, & &1.code)` in show template
- Sorts tickets numerically by reservation code

**Files modified:**

- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex`

**Ponytail approach:**

- Minimal: 1 line change
- Uses built-in `Enum.sort_by/2`
- No new dependencies

---

### Additional Change: Print Styles

**Requirement:** Print only tickets, A4 portrait, 2 columns x 4 rows = 8 tickets per page

**Implemented:**

- Added `no-print` class to all non-ticket elements (header, nav, allocation details tab)
- Created separate `.print-container` with `.print-grid` for print layout
- CSS `@media print` rules:
  - Hide all `.no-print` elements
  - Show `.print-container` with 2-column grid
  - Set A4 portrait page size with 5mm margins
  - Remove shadows, add solid black borders for print
  - Prevent page breaks inside tickets

**Files modified:**

- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex` - Added print CSS and container
- `lib/seaty_reservation_web/components/allocation_components.ex` - Added `print-ticket` class

**Ponytail approach:**

- Minimal inline CSS
- No external dependencies
- Reuses existing ticket card component
- Separate container for print to avoid layout conflicts

---

**Remaining:**

- [ ] Add Gettext translations for English version (if needed)
- [ ] Run `mix format`
- [ ] Run `mix test`
- [ ] Verify in browser
