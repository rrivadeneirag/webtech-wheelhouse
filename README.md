# Wheelhouse

The management app for **Wheelhouse**, a neighborhood bike repair shop. Alongside the
public pages (Home, Services & prices, Visiting the workshop, and About), the shop can
now **manage its whole workshop from the browser**: customers, bikes, repairs, services
and staff can each be listed, viewed, created, edited and deleted.

Built with **Ruby on Rails 8**, **PostgreSQL**, and **Bootstrap** (compiled from Sass,
no CDN). Every list and detail page reads from a seeded PostgreSQL database.

The design documents this app is built from live in the [`docs/`](docs/) folder: the
domain model, user stories, wireframes, and decisions.

## Prerequisites

Have these installed and working before setup:

- **Ruby 4.0.4** (the version pinned in `.ruby-version`)
- **Node.js 24 or newer** and npm — used only to compile Bootstrap's CSS
- **PostgreSQL 17**, running locally. The application connects as your own
  operating-system user, so a PostgreSQL role with that name must exist and be
  allowed to create databases.

## Setup

From a fresh clone, run these commands in order:

```bash
git clone https://github.com/rrivadeneirag/webtech-wheelhouse
cd webtech-wheelhouse
bundle install          # Ruby gems
npm install             # Bootstrap and the Sass toolchain
gem install foreman     # runs the web server and CSS watcher together
bin/rails db:setup      # creates the database, loads the schema, and seeds it
npm run build:css       # compiles Bootstrap into app/assets/builds/application.css
```

`bin/rails db:setup` is the single command that creates the database, loads the schema
from `db/schema.rb`, and seeds it with a full workshop (services, staff, customers,
bikes and repairs).

## Running the app

```bash
bin/dev
```

This starts the Rails server and the CSS watcher together. Open
<http://localhost:3000> in your browser.

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
- **Deleting** asks for confirmation first. A record that others still depend on (a
  service already charged, or a customer who still owns a bike) is kept and the page
  explains why.

Every save that fails re-shows the form with the values still filled in and the errors
listed, so nothing is lost.
