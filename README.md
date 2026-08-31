# Wheelhouse

The public website for **Wheelhouse**, a neighborhood bike repair shop. It has
four pages: Home, Services & prices, Visiting the workshop, and About. The site
is public and read-only — no customer, bike, or repair information appears.

Built with **Ruby on Rails 8**, **PostgreSQL**, and **Bootstrap** (compiled from
Sass, no CDN).

The design documents this app is built from live in the docs/ folder: the domain
model, user stories, wireframes, and decisions from Lab 3.

## Prerequisites

Install and have these working before setup:

- **Ruby 4.0.4** (see .ruby-version)
- **Node.js 24 or newer** and npm (used only to compile Bootstrap's CSS)
- **PostgreSQL 17**, running locally, with a role that can create databases

## Setup

Run these in order, from a terminal:

    git clone https://github.com/rrivadeneirag/webtech-wheelhouse
    cd webtech-wheelhouse
    bundle install
    npm install
    gem install foreman
    bin/rails db:create
    npm run build:css

## Running the app

    bin/dev

This starts the Rails server and the CSS watcher together, then open
http://localhost:3000 in your browser.
