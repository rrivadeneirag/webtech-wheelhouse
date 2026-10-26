# Wheelhouse — Decisions Record

Three questions the description does not answer. Each was chosen because the
answer changes the model. For each: the question, the assumption made in order to
keep working, and what would change in the model if the answer were the other one.

## 1. When is the customer's approval required before work starts?

The owner fixes small jobs the same afternoon, but calls the customer and waits
for a yes on bigger ones — without saying where the line is.

- **Assumption:** approval is a per-repair judgment made by the mechanic, not an
  automatic rule. A repair carries a flag the mechanic sets when the job needs a
  yes, which sends it from *Assessed* to *Awaiting approval* instead of straight
  to *In progress*.
- **If the answer is a fixed rule** (for example, any repair over a set amount, or
  any repair that needs parts, always needs approval): the flag would stop being
  the mechanic's choice and become derived. The model would need the rule's input
  — a price threshold, or a "needs parts" mark on services — and the
  *Assessed → Awaiting approval* transition would fire automatically.

## 2. Does the shop keep previous owners, or only the current one?

Bikes get sold, and the owner says the second owner deserves to know the fork was
replaced — but never says whether the shop records who owned the bike before.

- **Assumption:** only the current owner is stored, as `bikes.customer_id`. Repair
  history hangs off the bike, so a new owner still sees every past repair; the
  previous owner is overwritten when the bike changes hands.
- **If the answer is that previous owners must be kept** (to reach the person who
  paid for an old repair, or to keep a previous owner's personal data off the new
  owner's view): `bikes.customer_id` would be replaced by an `ownerships` table
  (bike_id, customer_id, from_date, to_date), and every repair would record the
  owner at the time it happened.

## 3. Can more than one mechanic work on a single repair?

Three mechanics share the workshop and each keeps their own notes, but the
description never says whether a single repair belongs to one of them or passes
between several.

- **Assumption:** one responsible mechanic per repair, stored as
  `repairs.mechanic_id`. That is enough to answer "who worked on this bike" when
  there is a dispute over a scratch.
- **If the answer is that several mechanics share a repair:** `repairs.mechanic_id`
  would move out into a join table (repair_id, staff_id, and perhaps the part of
  the work each did), so the repair could name every mechanic who touched it.

## 4. What role does a new account get by default?

Accounts have one of three roles — `owner`, `mechanic` or `counter` — and a new
account (someone who signs up on their own, with no staff member attached) has to
start somewhere.

- **Decision:** the default role is `counter`, the role with the fewest
  permissions. In the workshop the owner runs the shop, a mechanic works on the
  bikes, and the counter is the front desk — the narrowest job, with no ownership
  and no workshop work beyond receiving bikes and reading the lists. A stranger who
  signs up should land in the least-privileged role, so `counter` is the default.
  An account is lifted to `mechanic` or `owner`, or joined to a staff member, only
  from the seed or the console — never from a page.
