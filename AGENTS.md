# Agent Guide

This file is for AI agents working in this repository. It contains agent guidance only, never product requirements or user documentation.

## The documents

- [SPEC.md](SPEC.md) — the requirements: functional (what the images do) and non-functional (security, reproducibility, ease of maintenance, validation).
- [DECISIONS.md](DECISIONS.md) — the reasoning behind spec choices (numbered decisions). Explains *why*; the spec states *what*. Only non-obvious choices qualify: ones someone would get wrong or undo without the rationale.
- [README.md](README.md) — documentation for end users, not developers. Everything in it must be useful and actionable to an end user: concise, with no mechanism explanations or developer-facing detail.
- This file — agent rules.

Requirements, decisions, and rules are each grouped by topic: place a new or edited item next to the items it relates to most closely, and order sections to mirror SPEC.md where possible.

## Editing rules

- When editing code, recipes, units, scripts, or docs: follow the spec and do not violate it.
- When editing SPEC.md: follow DECISIONS.md and do not violate it.
- On a conflict (a change that satisfies one document by violating another): stop and ask the user whether to change the spec or the decision.

## Writing rules

- Keep each requirement's length and emphasis proportional to its risk: how likely it is to be ignored, and how bad the consequences are if it is.
- Keep replies to the user concise.