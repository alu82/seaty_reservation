# ID-002: Introduce Productions

## User story

As an Event Administrator I want to group my events to a production, so that i can organize my events better.

## Acceptance criteria

- [ ] A production can created in the admin interface
  - Consists of the mandatory field "name"
- [ ] The production attributes can be edited
- [ ] A production can be deleted
- [ ] Productions can be listed
- [ ] When creating an Event it has to be assigned to an existing production

## Technical notes

- This is a simple CRUD workflow for a new object type `productions`, use `phx.gen.html` to create the base
- Put the pages in the admin section by adding the new pages in `router.ex`
- Migration: this is a breaking change for existing events
  - all existing events are deleted
  - all existing  reservations are deleted
- Cascading deletion should be implemented
  - when a Production is deleted also all events are deleted and related reservations
  - when an event is deleted all related reservations are deleted
- Add this to the prompt when deleting an object

## Implementation Plan

### Analysis

- **User Story**: Admin wants to group events into productions for better organization
- **Core Entity**: Production with mandatory `name` field
- **Relationships**: Event belongs to Production (required), cascading deletes
- **Constraints**: Breaking change - existing data must be deleted before migration

### Success Boundary

- Public interface: Admin web UI at `/productions` (CRUD) + Event creation requires production selection
- Existing entry points affected: Event creation form, Event model, router
- User-visible outcomes: Production management pages, Event form includes production dropdown

### Implementation Slices

#### Slice 1: Generate Production Context and Schema

- **Behavior**: Create Production context with basic CRUD operations
- **Public interface**: `SeatyReservation.Productions` context, `Production` schema with `name` field
- **Verification**: Context functions exist and work in iex
- **Files**: `lib/seaty_reservation/productions.ex`, `lib/seaty_reservation/productions/production.ex`
- **Command**: `mix phx.gen.html Productions Production productions name:string`

#### Slice 2: Add Production to Router (Admin Section)

- **Behavior**: Production routes accessible under `/productions` with auth
- **Public interface**: `/productions` (index, new, create, edit, update, delete)
- **Verification**: Routes accessible in browser at `/productions`
- **Files**: `lib/seaty_reservation_web/router.ex`
- **Action**: Add `resources "/productions", ProductionController` in auth pipeline scope

#### Slice 3: Create Migration with Data Cleanup

- **Behavior**: Migration creates productions table and adds production_id to events
- **Public interface**: Database schema
- **Verification**: Migration runs successfully
- **Files**: `priv/repo/migrations/*_create_productions.exs`, `priv/repo/migrations/*_add_production_to_events.exs`
- **Action**:
  - Create production migration first
  - Create separate migration to add `production_id` to events as foreign key (required)
  - **Breaking**: Before running migrations, delete all existing events and reservations
  - Add `on_delete: :delete_all` to events association for cascading

#### Slice 4: Add Production Association to Event

- **Behavior**: Event belongs to Production (required field)
- **Public interface**: Event schema, Event changeset
- **Verification**: Event creation requires production_id
- **Files**: `lib/seaty_reservation/events/event.ex`, `lib/seaty_reservation/events.ex`
- **Action**:
  - Add `belongs_to :production, SeatyReservation.Productions.Production` to Event schema
  - Update changeset to require `:production_id`
  - Update context functions to handle production_id

#### Slice 5: Update Event Controller and Views

- **Behavior**: Event creation/edit shows production dropdown
- **Public interface**: Event form includes production select
- **Verification**: Can create event with selected production
- **Files**: `lib/seaty_reservation_web/controllers/event/event_controller.ex`, `lib/seaty_reservation_web/controllers/event/event_html.ex`, templates
- **Action**:
  - Load productions in new/edit actions
  - Add production select to event form template
  - Update form handling to include production_id

#### Slice 6: Implement Cascading Deletion

- **Behavior**: Deleting production deletes all its events and related reservations
- **Public interface**: Production delete action
- **Verification**: Deleting production removes all associated events and reservations
- **Files**: `lib/seaty_reservation/productions.ex`, `lib/seaty_reservation/events.ex`
- **Action**:
  - Add `has_many :events, SeatyReservation.Events.Event, on_delete: :delete_all` to Production schema
  - Add confirmation prompt for production deletion
  - Ensure event deletion cascades to reservations (already exists per requirements)

#### Slice 7: Update Event List to Show Production

- **Behavior**: Event list displays which production each event belongs to
- **Public interface**: Event index page
- **Verification**: Events show production name in listing
- **Files**: Event index template
- **Action**: Load production with events, display production name in table

#### Slice 8: Add Gettext Translations

- **Behavior**: All production-related text available in German and English
- **Public interface**: UI text
- **Verification**: All labels/buttons show in both languages
- **Files**: `priv/gettext/en/LC_MESSAGES/default.po`, `priv/gettext/de/LC_MESSAGES/default.po`
- **Action**: Add translations for production CRUD labels, messages, confirmations

### Dependencies and Risks

- **Dependency**: Slice 1 must complete before Slice 2
- **Dependency**: Slice 3 must run before Slice 4 (schema changes)
- **Dependency**: Slice 4 must complete before Slice 5 (event form needs productions)
- **Risk**: Data migration is breaking - requires manual deletion of existing data
- **Risk**: Cascading deletion could be accidental - need confirmation prompts

### Test Scenarios

- Create production with name
- Edit production name
- List productions
- Delete production (verify cascade)
- Create event with production selection
- Edit event production
- Verify event list shows production
- Verify cannot create event without production

### Components Affected

- `lib/seaty_reservation/productions.ex` (new)
- `lib/seaty_reservation/productions/production.ex` (new)
- `lib/seaty_reservation_web/controllers/production_controller.ex` (new)
- `lib/seaty_reservation_web/controllers/production_html.ex` (new)
- `lib/seaty_reservation_web/router.ex`
- `lib/seaty_reservation/events/event.ex`
- `lib/seaty_reservation/events.ex`
- `lib/seaty_reservation_web/controllers/event/event_controller.ex`
- Event templates
- Gettext translation files
- Database migrations

## Status

New
