# Wheelhouse — User Stories

Format: **As a [role], I want [need], so that [reason].**

Roles found in the description: **Counter staff**, **Mechanic**, **Customer**,
**Owner**, **Website visitor**. The two roles that do the day-to-day work of the
shop — Counter staff and Mechanic — each have more than three stories.

## Counter staff

1. As counter staff, I want to register a bike when it arrives — the customer's
   name and phone, and the bike's make/model and serial number — so that two
   similar bikes are never confused and I can always reach the right owner.
2. As counter staff, I want to look up whether a specific bike is ready without
   walking to the workshop, so that I can answer a customer on the phone right
   away.
3. As counter staff, I want to mark a bike as collected when its owner picks it
   up, so that the active board only shows bikes that are still in the shop.
4. As counter staff, I want to see the promised-ready date of each bike in the
   shop, so that I know which owners to call first.

## Mechanic

*(Stories 5, 6 and 7 come from splitting the epic at the end of this document.)*

5. As a mechanic, I want to record a bike's condition on arrival with photos, so
   that nobody argues later about who caused a scratch.
6. As a mechanic, I want to write a full diagnosis of what a bike needs — a
   paragraph, not four words — so that anyone in the shop can understand the work
   without asking me.
7. As a mechanic, I want to add the priced services a repair needs to build its
   estimate, so that the customer sees an accurate cost before we start.
8. As a mechanic, I want to mark a repair as ready when the work is finished, so
   that the counter knows the bike can be collected.

## Customer

9. As a customer, I want to approve or decline the estimate before any work
   begins, so that I stay in control of what I pay for.
10. As a customer, I want to see the full repair history of a bike, so that as
    its new owner I know what has already been replaced.
11. As a customer, I want to be given a promised-ready date when I drop off my
    bike, so that I know when to come back.

## Owner

12. As the owner, I want to see the bikes whose promised date has passed but that
    are not yet ready, so that I can act before the customer calls me.
13. As the owner, I want to raise the price list each January without changing
    what past invoices charged, so that last year's invoices stay accurate.

## Website visitor

14. As a website visitor, I want to see the shop's services and their prices
    online, so that I don't have to phone the shop to ask what a tune-up costs.

---

## The story that was too big

> **[EPIC — too big, split below]** As a mechanic, I want to record everything
> about a repair — the bike's condition on arrival, the diagnosis, and the priced
> services it needs — so that the repair is fully documented in one place.

**Why it is too big:** it bundles three independent pieces of value, each useful
on its own. The split is **by value, not by layer** — every piece is something a
person can use by itself, not a UI / logic / database slice of the same feature:

- **Story 5** — arrival photos (prevents damage disputes).
- **Story 6** — the written diagnosis (lets anyone understand the work).
- **Story 7** — the priced services / estimate (gives the customer a cost).

---

## Acceptance criteria

Each criterion is a statement that is simply **true or false** when you look at
the finished screen.

### Story 2 — Counter checks if a bike is ready

- Searching by the bike's serial number or the customer's phone shows that bike's
  current status.
- The status shown is exactly one of: Received, In progress, Ready, Collected.
- **If no bike matches the search, the screen shows a "No bike found" message —
  never a blank area.** *(empty case)*

### Story 9 — Customer approves or declines the estimate

- The screen lists every service on the repair with its price, and the total
  underneath.
- The customer can record exactly one decision: Approve or Decline.
- After a decision is recorded, the screen shows that decision and no longer
  offers the buttons.

### Story 12 — Owner sees overdue bikes

- The list shows only bikes whose promised date is before today and whose status
  is not Ready or Collected.
- Each row shows the bike, its owner, and how many days it is overdue.
- **If no bike is overdue, the screen shows "No overdue bikes" instead of an
  empty list.** *(empty case)*

### Story 14 — Public price list

- The page shows every service with its current price.
- No customer name, bike, or repair detail appears anywhere on the page.
- The prices shown are the current year's list.
