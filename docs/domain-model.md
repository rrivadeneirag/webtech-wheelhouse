# Wheelhouse — Domain Model

## Diagram

![Wheelhouse domain model](domain-model.png)

## DBML

The image above was produced from this code in [dbdiagram.io](https://dbdiagram.io).
It compiles as it stands.

```dbml
Table customers {
  id integer [primary key]
  name varchar [not null]
  phone varchar [not null]
}

Table bikes {
  id integer [primary key]
  make_model varchar [not null]
  serial_number varchar [not null, unique]
  colour varchar
  customer_id integer [not null, ref: > customers.id]
}

Table staff {
  id integer [primary key]
  name varchar [not null]
  role varchar [not null]
}

Table repairs {
  id integer [primary key]
  bike_id integer [not null, ref: > bikes.id]
  mechanic_id integer [ref: > staff.id]
  status varchar [not null]
  received_at datetime [not null]
  promised_for date
  diagnosis text
}

Table services {
  id integer [primary key]
  name varchar [not null]
  price decimal [not null]
  active boolean [not null, default: true]
}

Table repair_services {
  id integer [primary key]
  repair_id integer [not null, ref: > repairs.id]
  service_id integer [not null, ref: > services.id]
  charged_price decimal [not null]
}

Table photos {
  id integer [primary key]
  repair_id integer [not null, ref: > repairs.id]
  file_url varchar [not null]
  taken_at datetime [not null]
}
```

Relationships (each cardinality read in both directions):

- A customer owns many bikes; a bike has one current owner. Ownership can change,
  so repair history hangs off the bike, not the customer.
- A bike has many repairs over its life; a repair is for exactly one bike.
- A repair has many priced line items; each line item belongs to one repair.
- A service can appear on many repairs; a repair line item points to one service.
  `repair_services` is the many-to-many join between repairs and services.
- A repair has many arrival photos; a photo belongs to one repair.
- A staff member handles many repairs; a repair has one responsible mechanic.

## Lifecycle of a repair

`repairs.status` moves through these states:

**Received → Assessed → Awaiting approval → Approved / Declined → In progress → Ready → Collected**

Allowed transitions:

- **Received → Assessed** — a mechanic inspects the bike and writes the diagnosis.
- **Assessed → In progress** — a minor job that needs no approval starts directly.
- **Assessed → Awaiting approval** — the job needs the customer's yes first.
- **Awaiting approval → Approved** — the customer agrees to the estimate.
- **Awaiting approval → Declined** — the customer refuses.
- **Approved → In progress** — work begins once approved.
- **In progress → Ready** — the work is finished.
- **Ready → Collected** — the owner picks the bike up.
- **Declined → Collected** — the owner picks the bike up as it arrived.

Transitions that are **not** allowed:

- **Received → In progress** — work cannot start before the bike is assessed.
- **Received → Ready / Received → Collected** — a bike cannot be ready or leave
  before any assessment or decision.
- **Awaiting approval → In progress** — no work while the customer's yes is still
  pending; the owner is explicit that we wait before touching the bike.
- **Declined → In progress** — declined work is never carried out.
- **Ready → In progress** — a finished repair is not reopened; a new problem is a
  new repair, which keeps the bike's history correct.
- **Collected → any state** — once collected, the repair is closed.

## Entities and the stories that require them

| Entity | Story that requires it |
|---|---|
| customers | Story 1 — register the owner's name and phone |
| bikes | Story 1 & 10 — identify a bike by serial and carry its history |
| staff | Story 5 & 6 — the mechanic who photographs, diagnoses and is accountable |
| repairs | Stories 5–8 & 12 — the repair record and its promised date |
| services | Story 7 & 14 — the priced wall list, shown publicly |
| repair_services | Story 7, 9 & 13 — the services on a repair, at the price charged |
| photos | Story 5 — the arrival photos |

## Two decisions

### The thing and the copy of the thing

Every physical bike is its own row in `bikes`, identified by `serial_number`, and
every repair links to that specific bike through `repairs.bike_id`. That is what
prevents the March mix-up: two blue Trek Marlins are two rows with two serial
numbers, each with its own owner and its own repair history, so the shop hands
back the right one. A single `bikes` table with a `make_model` and a `quantity`
column ("2 × Trek Marlin") could count how many Marlins are on the rack, but it
could not answer which physical bike belongs to which customer, nor hold a repair
history for one of them and not the other.

### Derived, or stored?

**Deliberately not stored (derived):** the total cost of a repair. There is no
`total` column on `repairs`; the total is the sum of `charged_price` across that
repair's `repair_services` rows. Storing it would risk a total that silently
disagrees with its own line items.

**Looks derivable but stored anyway:** `repair_services.charged_price`. It looks
like it could be read from `services.price`, but it is stored as a snapshot taken
when the service is added to the repair. If it were not stored, recomputing an old
repair's cost from the current `services.price` would change last year's invoices
every January when the wall list goes up — exactly what the owner says must never
happen. Storing it also lets a mechanic charge a regular less than the list
without altering the catalogue.
