# ID-004: Persist Quotation

## User story

As the responsible for events I want that my allocations are stored so that I can access them instead of recreating them every time.

## Acceptance criteria

- [ ] Allocations are persisted
- [ ] Allocations have a is_up_to_date flag that shows if an allocation is still valid for the given reservations
- [ ] Allocations are shown on the events detail page below the general event information
  - Date taken
  - is_up_to_date
  - Action: View
  - Click on the row opens the allocation show page

## Technical notes

### Database Design

- Table Name `allocations`
- Columns
  - created
  - result of type map: for easy storing and loading the result off the allocation method is stored in the database
  - link to event: 1 event can have many allocations
- When a allocation is loaded a virual field is_up_to_date is added
  - true when the created timestamp is greater than the max modified timestamp of the reservations belonging to an event
  - false otherwise

### User Flow

- Allocation Link on event listing is removed
- Allocations are listed on events detail page
- Button to create a new allocation via the existing POST endpoint
- Link to delete an allocation via a newly created DELETE endpoint

## Implementation Plan

### 1. Database Migration

- Create migration `priv/repo/migrations/*_create_allocations.exs`
  - Table: `allocations`
  - Columns: `event_id` (references events), `result` (map type), `created` (timestamp, default: now)
  - Add index on `event_id`

### 2. Schema

- Create `lib/seaty_reservation/allocations/allocation.ex`
  - Schema with fields: `event_id`, `result` (map)
  - Use `timestamps()` for created/updated timestamps
  - Belongs to `:event`, on_delete: :delete_all (cascade delete)
  - Virtual field `is_up_to_date` computed via function

### 3. Context (Allocations)

- Update `lib/seaty_reservation/allocations.ex`
  - Add `Allocation` alias
  - Add CRUD functions:
    - `create_allocation(event_id)` - persists allocation result
    - `get_allocation!(id)` - get single allocation
    - `list_allocations_by_event(event_id)` - list for event
    - `delete_allocation(allocation)` - delete allocation
  - Add `is_up_to_date/1` function:
    - Query max `updated_at` from reservations for the event
    - Return `allocation.created > max_updated_at`

### 4. Router

- Update `lib/seaty_reservation_web/router.ex`
  - Change POST `/events/:event_id/allocations` to create and persist
  - Add GET `/allocations` (nested under events: `/events/:event_id/allocations`)
  - Add GET `/allocations/:id` for show
  - Add DELETE `/allocations/:id`

### 5. Controller

- Update `lib/seaty_reservation_web/controllers/allocation/allocation_controller.ex`
  - `create`: persist allocation, redirect to event show
  - Add `index(event_id)`: list allocations for event
  - Add `show(id)`: show allocation details
  - Add `delete(id)`: delete allocation, redirect back

### 6. HTML Templates

- Create `lib/seaty_reservation_web/controllers/allocation/allocation_html/index.html.heex`
  - Table with columns: Date taken, is_up_to_date, Action (View)
  - Click row navigates to show
- Update `show.html.heex`: use persisted allocation data

### 7. Event Show Page

- Update `lib/seaty_reservation_web/controllers/event/event_controller.ex`
  - Preload allocations in `show/2`
- Update `lib/seaty_reservation_web/controllers/event/event_html/show.html.heex`
  - Add allocations table below event info
  - Columns: Date taken, is_up_to_date, Action: View link
  - Delete link (with prompt similar to other  delete links)

### 8. Event Listing Page

- Update `lib/seaty_reservation_web/controllers/event/event_html/index.html.heex`
  - Remove allocation link action column

### 9. Tests

- Update `test/seaty_reservation/allocations_test.exs`
  - Add tests for persistence
  - Add tests for `is_up_to_date` flag

### Dependencies Flow

1. Migration → 2. Schema → 3. Context → 4. Router → 5. Controller → 6. Templates → 7. Event Show → 8. Event Listing → 9. Tests

## Status

Done
