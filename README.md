# Wheelhouse

The public website for **Wheelhouse**, a neighborhood bike repair shop. It has four
pages: Home, Services & prices, Visiting the workshop, and About. The site is public
and read-only — no customer, bike, or repair information appears.

Built with **Ruby on Rails 8**, **PostgreSQL**, and **Bootstrap** (compiled from Sass,
no CDN). The Services page reads the wall list from a seeded PostgreSQL database.

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
<http://localhost:3000> in your browser — the Services page shows the seeded wall list.
