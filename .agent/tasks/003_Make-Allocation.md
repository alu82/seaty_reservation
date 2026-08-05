# ID-003: Make Allocation

## User story

As the reservation responsible, I want to be able to make the allocation, in oder to not have to switch tools.

## Acceptance criteria

- [ ] Reservations for an Event are allocated in the event room
- [ ] The rules are followed
- [ ] if a reservation could not be allocated it shown as not allocated

## Technical notes

- Allocations are transient objects that don't exist in the database
- An Allocation can be triggered in the event listing page via a link between (the link is between Reservations and Edit)
- The allocation Result is shown as described in the visualisation chapter
- not allocated groups are shown at the bottom
- The rules of the allocation are quite complex. They have been done so far in an [jupyter notebook](seaty-allocation.ipynb). In this notebook the allocation is done for 6 events. For this story it should be done for one specific event (triggered on the listing page)
- Not in scope: the notebook has also some visualization via a html generation. This is not part of this story. Focus is the allocation algorithm and the endpoints.

## Visualization

Create a visualization as followed:

```ascii

                                          STAGE
══════════════════════════════════════════════════════════════════════════════════════════════════════════════

                ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
                │ Row 1        │  │ Row 2        │  │ Row 3        │  │ Row 4        │
                │              │  │              │  │              │  │              │
                │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│
                │ │S1  │ │S2  ││  │ │S1  │ │S2  ││  │ │S1  │ │S2  ││  │ │S1  │ │S2  ││
                │ └────┘ └────┘│  │ └────┘ └────┘│  │ └────┘ └────┘│  │ └────┘ └────┘│
                │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│  │ ┌────┐ ┌────┐│
                │ │S3  │ │S4  ││  │ │S3  │ │S4  ││  │ │S3  │ │S4  ││  │ │S3  │ │S4  ││
                │ └────┘ └────┘│  │ └────┘ └────┘│  │ └────┘ └────┘│  │ └────┘ └────┘│
                │      ...     │  │      ...     │  │      ...     │  │      ...     │
                └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘



┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Row 5            │  │ Row 6            │  │ Row 7            │  │ Row 8            │  │ Row 9            │
├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
│ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │
│ │ S1 │  │ S2 │   │  │ │ S1 │  │ S2 │   │  │ │ S1 │  │ S2 │   │  │ │ S1 │  │ S2 │   │  │ │ S1 │  │ S2 │   │
│ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │
│                  │  │                  │  │                  │  │                  │  │                  │
│ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │
│ │ S3 │  │ S4 │   │  │ │ S3 │  │ S4 │   │  │ │ S3 │  │ S4 │   │  │ │ S3 │  │ S4 │   │  │ │ S3 │  │ S4 │   │
│ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │
│                  │  │                  │  │                  │  │                  │  │                  │
│        ⋮         │  │        ⋮          │  │        ⋮          │  │        ⋮          │  │        ⋮         │
│                  │  │                  │  │                  │  │                  │  │                  │
│ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │  │ ┌────┐  ┌────┐   │
│ │S23 │  │S24 │   │  │ │S23 │  │S24 │   │  │ │S23 │  │S24 │   │  │ │S23 │  │S24 │   │  │ │S23 │  │S24 │   │
│ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │  │ └────┘  └────┘   │
└──────────────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘
```

Use the following styles if possible:

Layout

```html
<div class="min-h-screen bg-slate-100 p-8">
    <div class="mb-8 text-center">
        <h2 class="text-3xl font-bold text-slate-800">Stage</h2>
    </div>

    <div class="grid grid-cols-4 gap-6">
        <!-- Table -->
    </div>
</div>
```

Row

```html
<div class="rounded-xl border border-slate-300 bg-slate-200 shadow-sm overflow-hidden">

    <div class="border-b border-slate-300 bg-slate-300 px-4 py-3">
        <div class="font-semibold text-slate-800">
            Table 1
        </div>
    </div>

    <div class="space-y-3 p-4">

        <!-- Seat row -->

    </div>

</div>
```

Seat Row

```html
<div class="grid grid-cols-2 gap-3">
    <!-- left seat -->

    <!-- right seat -->
</div>
```

```html
<div
    class="rounded-lg border border-slate-300 bg-white p-3 shadow-sm transition hover:shadow-md hover:border-slate-400 cursor-pointer">

    <div class="text-xs font-semibold uppercase tracking-wide text-slate-500">
        Seat 3
    </div>

    <div class="mt-1 text-sm font-mono text-slate-600">
        Reservation Code
    </div>

    <div class="mt-2 text-sm font-semibold text-slate-900">
        Name
    </div>

</div>
```

## Implementation Plan

### 1. Understand the requested behavior

- User triggers allocation for a specific event from the event listing page
- System allocates reservations to seats following complex business rules
- Show unallocated reservations separately at the bottom

**Algorithm rules:**

- reservations with high priority should be assigned first if possible
- a reservation should be assigned to the best possible option
  - there is a metric for each seat `distance`
  - the best option is the option with the least distance.
  - there is a parameter distance_range that acts as a fallback: if the best option is not possible and the distance of the second best option is not worse than distance_range than the second best option is also valid (and so on): second_option_distance - first_option_distance <= DISTANCE_RANGE
- More reservations can be aggregated to a group: groups sit together
- Groups with even number of people cannot start on a seat with an uneven number.
- When a reservation has a rowwish it is allocated there
- when a group/or single reservation cannot be allocated, the next reservation is allocated, and then there is a retry for the not assigned reservation/group

### 2. Define the success boundary

**Public interface:**

- POST `/events/:event_id/allocations` - triggers allocation for specific event, renders results directly

**User-visible outcomes:**

- Allocation link visible and functional in event listing between Reservations and Edit
- Allocation results page displays table with row, seat, reservation code, group
- Unallocated reservations listed at bottom of results page
- No database storage of allocation results (transient)

### 3. Plan the change

**Slice 1: Implement allocation algorithm in Elixir**

- Port Python algorithm from notebook to `SeatyReservation.Allocations`
- Create `allocate_event/1` function that takes event_id
- Implement helper functions: `get_distance/2`, `find_all_options/2`, `find_options/3`, `validate_options/2`, `allocate_seat/3`, `get_row_wishes/2`
- Create room layout structure (13 rows: 4 rows of 24 seats, 5 rows of 19 seats, 4 rows of 4 seats)
- Group reservations by group field, respecting priority order
- Return allocation result with assigned seats and unallocated groups

**Slice 2: Update Allocations context**

- Replace dummy `create_allocation/1` with actual implementation
- Add `get_allocation_result/1` to return structured result for display
- Result format: `%{assigned: [{row, seat, code, group}], unallocated: [{code, group, seats}]}`

**Slice 3: Update AllocationController**

- `create/2`: fetch event, get reservations, call allocation, render results directly
- Remove `show/2` action and route (not needed for transient allocations)

**Slice 4: Create allocation result template**

- Create `allocation_html/` directory with `show.html.heex`
- Display table with columns: row, seat, reservation code, group
- Display unallocated section at bottom
- Add back link to event listing

**Slice 5: Update event listing template**

- Uncomment and fix allocation link between Reservations and Edit
- Link should POST to `/events/:event_id/allocations`

**Slice 6: Add AllocationHTML view**

- Create `allocation_html.ex` to render the show template

**Expected test scenarios:**

- Event with no reservations: shows empty allocation with no unallocated
- Event with reservations that all fit: all assigned, no unallocated
- Event with too many reservations: some unallocated at bottom
- Reservations with preferred_row: allocation respects preferences
- Priority ordering: higher priority (lower prio number) allocated first

**Components affected:**

- `lib/seaty_reservation/allocations.ex` - main algorithm
- `lib/seaty_reservation_web/controllers/allocation/allocation_controller.ex` - endpoint logic
- `lib/seaty_reservation_web/controllers/allocation/allocation_html.ex` - view (new)
- `lib/seaty_reservation_web/controllers/allocation/allocation_html/show.html.heex` - template (new)
- `lib/seaty_reservation_web/controllers/event/event_html/index.html.heex` - add link

**Dependencies and risks:**

- Algorithm complexity: Python notebook has ~100 lines of allocation logic
- Room layout: hardcoded in notebook (4+5+4 rows with specific seat counts)
- Distance calculation: complex formula based on row and seat position
- Group handling: reservations grouped by `group` field, allocated together
- Performance: algorithm iterates through groups, may need optimization for large events

### 4. Completion

Implementation brief: Port allocation algorithm from Python notebook to Elixir in Allocations context. Update AllocationController to trigger allocation and display results. Add allocation link to event listing. Create result template showing assigned seats and unallocated reservations.

---

## Status

New
