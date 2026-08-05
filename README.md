# ACH QA

Quantitative analysis code for the ACH evaluation.

## What lives here vs. what lives on Drive

This repo tracks **code only** — the `.do` files in `Programs/`. Data, logs, and output
deliverables are never committed here; they live in the `ACH - Eval` folder on Drive instead
(`My Drive/ACH - Eval`), and `Programs/00_master.do` points at that location via a set of global
path macros.

To work on this project on a new machine, update the paths at the top of `00_master.do` to point
at wherever `ACH - Eval` is mounted locally, then run `00_master.do`.

## Contributing

Make changes on a branch, push it, and open a pull request into `main` rather than committing
directly to `main` — this gives a teammate a chance to review before anything becomes official.
