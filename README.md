# Mergen

A simple application for spaced repetition study in Elixir.

Documentation: https://pauljxtan.github.io/mergen

## Quickstart

- Install dependencies: `mix deps.get`
- Create, migrate, and seed database: `mix ecto.setup`
- Install node dependencies: `cd assets && npm install` (might eventually just remove this)
- Start server: `mix phx.server`

Visit [http://localhost:4000](http://localhost:4000).

## Motivation

From a user perspective: to have a hackable SRS system that I can tailor to my personal preferences.

From a learning perspective: to get better at Elixir, Phoenix, and other tooling and libraries (possibly GraphQL).

## Stack

[Phoenix](https://github.com/phoenixframework/phoenix) with a SQLite database.

This project started out as a plain old Elixir library, but I eventually realized that it would be easier to get a handle on the requirements with a frontend to go with it.

## Roadmap

Still very early days...

High-priority features:

- [x] Create, edit, and delete study items
- [x] JSON import and export
- [ ] Retrieve a random queue of items due for lessons or reviews
- [ ] Do lessons and reviews

Medium-priority features:

- [ ] GraphQL API
- [ ] Keep a review history (needs a new data model)

Low-priority features:

- [ ] Generate review summaries, statistics, etc.
- [ ] Portable escript (no idea if this is feasible)

## APIs

### Backend API

By design, the programmatic API in `lib/mergen.ex` can be easily decoupled from the Phoenix app and plugged in elsewhere. Simply grab `lib/mergen.ex`, along with the core library folder `lib/mergen/`, and configure your `Ecto.Repo` settings accordingly.

### Web API

I also plan to make some sort of web API (probably GraphQL) via the Phoenix endpoints in the future, after the frontend is actually usable.

## Scheduling algorithm

Review intervals are computed as 2<sup>(level + 1)</sup>, in which the SR level increases or decreases by one with each answer.

| SR Level | Review interval            |
| -------- | -------------------------- |
| 0        | N/A (first time)           |
| 1        | 4 hours                    |
| 2        | 8 hours                    |
| 3        | 16 hours                   |
| 4        | 32 hours / ~1.3 days       |
| 5        | 64 hours / ~2.7 days       |
| 6        | 128 hours / ~5.3 days      |
| 7        | 256 hours / ~1.5 weeks     |
| 8        | 512 hours / ~3 weeks       |
| 9        | 1024 hours / ~1.5 months   |
| 10       | 2048 hours / ~3 months     |
| 11       | 4096 hours / ~6 months     |
| 12       | 8192 hours / ~1 year       |
| 13       | Infinite (no more reviews) |

This is pretty naive and will be refined at some point.

## Some background on SR

The general idea behind spaced repetition (SR) is to exploit changes in the forgetting curve as we recall things. Namely, empirical studies suggest that it each time we successfully retrieve something from memory, we forget it more slowly than before—in other words, the forgetting curve becomes less steep. (More details here). The goal of spaced repetition study is to optimize the intervals between reviews through algorithmic scheduling, allowing us to memorize more with less effort.

https://en.wikipedia.org/wiki/Spaced_repetition
