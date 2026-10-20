# Wheelhouse JSON API — v1

The API that programs (not browsers) use to read Wheelhouse. Every route is under
`/api/v1/`. Every response is JSON with `Content-Type: application/json`, including
errors — never an HTML page or a redirect, whatever the request's `Accept` header.

Base URL in development: `http://localhost:3000/api/v1`

## Routes

| Verb | Path                    | Token? | Statuses it answers      |
|------|-------------------------|--------|--------------------------|
| GET  | `/api/v1/services`      | no     | 200                      |
| GET  | `/api/v1/services/:id`  | no     | 200, 404                 |
| POST | `/api/v1/services`      | yes    | 201, 400, 401, 422       |
| GET  | `/api/v1/repairs`       | yes    | 200, 400, 401            |
| GET  | `/api/v1/repairs/:id`   | yes    | 200, 401, 404            |

Reading the price list (`GET /services`, `GET /services/:id`) is public. Reading
repairs and creating a service need a token (see **Authentication**).

`GET /api/v1/repairs` accepts an optional `?state=` filter whose value must be one
of the lifecycle states (`received`, `assessed`, `awaiting_approval`, `approved`,
`declined`, `in_progress`, `ready`, `collected`). Any other value answers `400`.

## Authentication

Protected routes read a token from the `Authorization` header, Bearer scheme:

```
Authorization: Bearer YOUR_TOKEN
```

A token in the query string or the body is not accepted. A missing or wrong token
answers `401` before the action runs. The token lives in the application's encrypted
credentials under `api_token` (it is not in the code; `config/master.key` is not
committed). See the project README for how to set it.

## Document shapes

### A service

The same shape is returned by `GET /services`, `GET /services/:id` and `POST /services`.
`price` travels as a **string with two decimals** (see **Decisions**); `times_charged`
is how many repairs the service has been charged on — a value that is not a column.

```json
{
  "id": 3,
  "name": "Brake bleed",
  "price": "30.00",
  "times_charged": 4
}
```

### A collection of services

`GET /services` answers a JSON array of service documents:

```json
[
  { "id": 1, "name": "Bottom bracket service", "price": "40.00", "times_charged": 2 },
  { "id": 2, "name": "Brake bleed",            "price": "30.00", "times_charged": 4 }
]
```

### A repair

`total`, `overdue` and `customer_answer` are values that are not columns. No foreign
key appears; the bike and the customer are nested inside. Dates are ISO `YYYY-MM-DD`.

```json
{
  "id": 1,
  "state": "received",
  "received_on": "2026-10-05",
  "promised_on": null,
  "handed_back_on": null,
  "bike": {
    "make_model": "Trek Marlin 5",
    "serial_number": "WTU100001"
  },
  "customer": {
    "name": "Ana Morales"
  },
  "lines": [
    { "service": "Tune-up",    "charged": "45.00" },
    { "service": "Wheel true", "charged": "20.00" }
  ],
  "total": "65.00",
  "overdue": false,
  "customer_answer": null
}
```

`GET /repairs` answers a JSON array of repair documents (same shape, no paging).

### An error

Every error — `400`, `401`, `404`, `422` — has one shape: an object with a single
key `errors`, whose value is a list of strings. A client handles every error in one
place.

```json
{ "errors": ["A valid API token is required for this route"] }
```

```json
{ "errors": ["Price must be greater than 0", "Name can't be blank"] }
```

## Decisions

- **A price travels as a string** with two decimals (e.g. `"30.00"`), in every
  document that carries a price (`price` on a service, `charged` on a line, `total`
  on a repair). A string keeps the exact money value the shop uses and never arrives
  as a binary float the client has to round.
- **A repair document leaves out** the customer's phone (the accounting program bills
  by what was charged, not by calling anyone), the mechanic, and the bike's colour —
  none of them is needed to account for a repair. It also carries **no foreign key**
  (`bike_id`, `mechanic_id`): a program wants the bike and the customer themselves,
  nested, not an id it would have to resolve with a second request.
- **`customer_answer`** reports the customer's decision on the quote as the lifecycle
  names it: `"Declined"` when the repair was declined, `"Approved"` once the shop has
  moved past approval (approved, in progress, ready or collected), and `null` while
  the repair is still being received, assessed or awaiting approval.
