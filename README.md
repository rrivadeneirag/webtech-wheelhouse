# Wheelhouse

The management app for **Wheelhouse**, a neighborhood bike repair shop. Signed-in
staff **manage the whole workshop from the browser**: customers, bikes, repairs,
services and staff can each be listed, viewed, created, edited and deleted. The public
price list stays open to everyone; everything else needs an account (see
[Accounts & sign-in](#accounts--sign-in)).

Built with **Ruby on Rails 8**, **PostgreSQL**, and **Bootstrap** (compiled from Sass,
no CDN). Every list and detail page reads from a seeded PostgreSQL database.

The design documents this app is built from live in the [`docs/`](docs/) folder: the
domain model, user stories, wireframes, and decisions.

## Prerequisites

Have these installed and working before setup:

- **Ruby 4.0.4** (the version pinned in `.ruby-version`)
- **Node.js 24 or newer** and npm — compiles the CSS (Bootstrap + Trix) and provides
  the Trix rich-text editor used for the diagnosis
- **libvips**, for resizing the intake-photo thumbnails. On macOS: `brew install vips`
  (Linux: `apt-get install libvips`).
- **PostgreSQL 17**, running locally. The application connects as your own
  operating-system user, so a PostgreSQL role with that name must exist and be
  allowed to create databases.

## Setup

From a fresh clone, run these commands in order:

```bash
git clone https://github.com/rrivadeneirag/webtech-wheelhouse
cd webtech-wheelhouse
bundle install          # Ruby gems
npm install             # Bootstrap, the Sass toolchain and the Trix editor
gem install foreman     # runs the web server and CSS watcher together
bin/rails db:setup      # creates the database, loads the schema, and seeds it
npm run build:css       # compiles the CSS (Bootstrap + Trix) into app/assets/builds
```

`bin/rails db:setup` is the single command that creates the database, loads the schema
from `db/schema.rb`, and seeds it with a full workshop (services, staff, customers, bikes and repairs,
including intake photos and diagnoses for the repairs).

## Running the app

```bash
bin/dev
```

This starts the Rails server and the CSS watcher together. Open
<http://localhost:3000> in your browser. Every page but the price list asks you to
sign in first — use one of the seeded accounts in [Accounts & sign-in](#accounts--sign-in)
(for example `martin@wheelhouse.cl` / `owner-martin-2026`). Once signed in, the
**Repairs** page shows a thumbnail next to every repair that has intake photos — proof
the seeded media and the image variants (via libvips) are working.

## The JSON API

Programs that are not a browser read Wheelhouse through a versioned JSON API under
`/api/v1` — the full reference is in [`docs/api.md`](docs/api.md). Reading the price
list is public; reading repairs and registering a service need a token.

### Set the API token

The token lives in the app's **encrypted credentials**, never in the code. Because
`config/master.key` is not committed, set your own token on a fresh clone:

```bash
rm config/credentials.yml.enc config/master.key   # drop the keys you can't read
EDITOR="nano" bin/rails credentials:edit           # opens a fresh credentials file
```

Add one line, then save and close the editor:

```yaml
api_token: choose-any-secret-string
```

That is the only place the token lives; none is written anywhere in the repository.

### The price-list page

The published page is at
<https://rrivadeneirag.github.io/webtech-lab-10/> and reads this API with `fetch`.
For the page to find the API, run this app on **port 3000** (which `bin/dev` uses) —
that is the origin the page points at. CORS allows the page's origin (and a local dev
server on port 8000); every other origin is refused.

### Asking the API from the terminal

The public price list:

```bash
curl http://localhost:3000/api/v1/services
```

A route that needs the token (use the token you set above):

```bash
curl -H "Authorization: Bearer choose-any-secret-string" \
     http://localhost:3000/api/v1/repairs
```

## Accounts & sign-in

Most pages require signing in. The public price list (`/services` and a service's
page) stays open; everything else — customers, bikes, repairs, staff and the home
pages — needs an account. Accounts have a role (`owner`, `mechanic` or `counter`),
and each repair records the account that took it in.

You can sign up from the sign-in page, or use one of the seeded accounts below.
**These accounts exist only in development (they come from the seed).**

| Email                    | Role     | Password              |
|--------------------------|----------|-----------------------|
| martin@wheelhouse.cl     | owner    | owner-martin-2026     |
| diego@wheelhouse.cl      | mechanic | mechanic-diego-2026   |
| camila@wheelhouse.cl     | mechanic | mechanic-camila-2026  |
| ignacio@wheelhouse.cl    | mechanic | mechanic-ignacio-26   |
| valentina@wheelhouse.cl  | counter  | counter-valentina-26  |
| helper@wheelhouse.cl     | counter  | helper-default-2026   |

The first five are joined to staff members; `helper@wheelhouse.cl` belongs to no
staff member and has the default role.

### Emails in development

The app never sends real email. In development every message — the welcome email
after sign-up and the password-reset link — is **written to a file** under
`tmp/mails/`. Open the newest file there to read the message and follow its links
(the password-reset link opens the reset form in the app running locally). No SMTP
server, provider or credential is involved.

## Managing the workshop

Every resource is reachable from the top navigation and supports the full set of
actions from the browser — no console needed:

- **Customers, Bikes, Repairs, Services, Staff** — each has a list (index) with a
  **New** button, a detail page with **Edit** and **Delete** buttons, and a form shared
  between creating and editing.
- **Bikes** can be created from the bikes page or straight from a customer's page, with
  the owner already chosen.
- **Repairs** are created with their service lines in the same form: pick a bike, a
  mechanic and a status, then add the services charged and the price of each. Blank
  service rows are ignored, and existing lines can be removed with a checkbox.
- **Repairs** also carry **intake photos** (uploaded from the repair's form, validated
  by type and size, shown as thumbnails in every list and full size on the repair's
  page) and a **diagnosis** written in a rich-text editor.
- **Deleting** asks for confirmation first. A record that others still depend on (a
  service already charged, or a customer who still owns a bike) is kept and the page
  explains why.

Every save that fails re-shows the form with the values still filled in and the errors
listed, so nothing is lost.
