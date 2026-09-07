# Wheelhouse

The public website for **Wheelhouse**, a neighborhood bike repair shop. It has
four pages: Home, Services & prices, Visiting the workshop, and About. The site
is public and read-only — no customer, bike, or repair information appears.

Built with **Ruby on Rails 8**, **PostgreSQL**, and **Bootstrap** (compiled from
Sass, no CDN). The Services page reads the wall list from a seeded PostgreSQL
database.

The design documents this app is built from live in the docs/ folder: the domain
model, user stories, wireframes, and decisions.

## Prerequisites

Install and have these working before setup:

- **Ruby 4.0.4** (see .ruby-version)
- **Node.js 24 or newer** and npm (used only to compile Bootstrap's CSS)
- **PostgreSQL 17**, running locally. The application connects as your local
  user, so that role must exist and be allowed to create databases.

## Setup

Run these in order, from a fresh clone:

    git clone https://github.com/rrivadeneirag/webtech-wheelhouse
    cd webtech-wheelhouse
    bundle install
    npm install
    gem install foreman
    bin/rails db:setup
    npm run build:css

`bin/rails db:setup` creates the database, loads the schema, and seeds it with a
full workshop (services, staff, customers, bikes and repairs).

## Running the app

    bin/dev

This starts the Rails server and the CSS watcher together. Open
http://localhost:3000 in your browser; the Services page shows the seeded wall list.
