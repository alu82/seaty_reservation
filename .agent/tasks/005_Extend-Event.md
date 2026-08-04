# ID-005: Extend Event

## User story

As a responsible for events I want to have a Code that i can configure for an event.
That code is used instead of the event Id when creating the reservation code.

## Acceptance criteria

- [ ] Event is extended by a new attribute code of type String
  - Cannot be null
  - Should be visible as field in the create form
  - Should be visible in the edit form of the event
  - no need to show it in the event listing
- [ ] The code is used when generating the reservation code as praefix

## Technical notes

- Migration: for existing events the new field should be filled with the event_id
- in `lib/seaty_reservation/reservations.ex` the relevant method is `get_next_code`: for an event with code A it should create codes like A001, A002, ... The length of the code is 4.

## Out of scope

## Implementation Plan

### 1. Understand the requested behavior

- Add `code` field (String, non-nullable) to Event schema
- Use this code as prefix for reservation codes (format: `{event.code}{sequential_number}` with 4-digit padding)
- Display code field in create and edit forms
- For existing events, populate code with event_id value

### 2. Define the success boundary

**Public interfaces affected:**

- `SeatyReservation.Events.Event` schema - new `:code` field
- `SeatyReservation.Events` context - changeset accepts `:code`
- `SeatyReservation.Reservations.get_next_code/1` - uses event.code instead of event_id
- Web: `EventController` new/edit forms render code field

**User-visible outcomes:**

- Event create/edit forms include code input
- Reservation codes use event code prefix (e.g., "ABC0001" instead of "1001")
- Existing reservations unaffected; new ones use new format

### 3. Plan the change

#### Slice 1: Migration

- **Behavior**: Add `code` column to events table, non-nullable, with default value
- **Interface**: Database schema
- **Verification**: Migration runs successfully
- **Risk**: Data migration for existing events
- **Files**: `priv/repo/migrations/*_add_code_to_events.exs`

#### Slice 2: Schema update

- **Behavior**: Add `:code` field to Event schema
- **Interface**: `SeatyReservation.Events.Event` module
- **Verification**: Schema compiles, tests pass
- **Files**: `lib/seaty_reservation/events/event.ex`

#### Slice 3: Changeset update

- **Behavior**: Accept and validate `:code` in changeset
- **Interface**: `SeatyReservation.Events.Event.changeset/2`
- **Verification**: Can create/update events with code
- **Files**: `lib/seaty_reservation/events/event.ex`

#### Slice 4: Reservation code generation

- **Behavior**: `get_next_code/1` uses event.code as prefix
- **Interface**: `SeatyReservation.Reservations.get_next_code/1`
- **Verification**: Reservation codes have correct prefix format (e.g., "ABC0001")
- **Files**: `lib/seaty_reservation/reservations.ex`

#### Slice 5: Web form update

- **Behavior**: Add code field to new/edit event forms
- **Interface**: `EventHTML.event_form/1` template
- **Verification**: Form renders code input, submits correctly
- **Files**: `lib/seaty_reservation_web/controllers/event/event_html/event_form.html.heex`

### Test scenarios

- Create new event with code "ABC" → reservations get codes ABC0001, ABC0002, ...
- Edit existing event code → new reservations use new code
- Existing reservations keep their codes (no retroactive change)
- Form validation rejects empty code
- Event listing doesn't show code column

### Components affected

- `lib/seaty_reservation/events/event.ex` (schema + changeset)
- `lib/seaty_reservation/reservations.ex` (get_next_code)
- `lib/seaty_reservation_web/controllers/event/event_html/event_form.html.heex` (form)
- `priv/repo/migrations/*_add_code_to_events.exs` (migration)

### Dependencies and risks

- **Dependency**: Migration must run before code is used
- **Risk**: Existing events without code will break reservation creation → mitigated by backfilling with event_id
- **Risk**: Reservation code format change → existing reservations unaffected, only new ones use new format

### Implementation brief

Create migration adding non-nullable `code` to events with default. Update Event schema and changeset. Modify `get_next_code/1` to fetch event.code and use as prefix with 4-digit sequential number. Add code field to event form. Run migration to backfill existing events with their event_id as code.

## Status

Done
