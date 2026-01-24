# CLAUDE.md

This file provides guidance to Claude Code for the Bifrost Events project.

## Project Overview

Bifrost Events is an Elixir library for handling financial events (payments, payouts, deposits, settlements) in a Bifrost payment processing system. It provides standardized event structures with schema validation using Zot.

## Development Commands

```bash
# Compile with warnings as errors
mix compile --warnings-as-errors

# Run tests (always compile first)
MIX_ENV=test mix compile --force && mix test

# Format code
mix format
```

## Project Structure

```
lib/bifrost/
├── event.ex              # Main module - discriminated union of all event types
├── event/
│   ├── __notation__.ex   # DSL macro for defining events (use Bifrost.Event.Notation)
│   ├── __zot_custom__.ex # Custom Zot validators (Zc alias)
│   └── *.ex              # Individual event modules
├── inbox.ex              # Ecto schema for incoming events
├── outbox.ex             # Ecto schema for outgoing events
└── migration.ex          # Database migration generator
```

## Adding New Events

To add a new event (e.g., `refund_created`), complete all 5 steps below. Keep all entries **alphabetically sorted**.

### Step 1: Create the event module

Create `lib/bifrost/event/refund_created.ex`:

```elixir
defmodule Bifrost.Event.RefundCreated do
  use Bifrost.Event.Notation

  defevent request_id: Zc.non_empty_string(),
           amount: Zc.money(:cents),
           reason: Zc.non_empty_string() |> Z.optional()
end
```

### Step 2: Add alias in `lib/bifrost/event.ex` (alphabetically sorted)

```elixir
alias Bifrost.Event.RefundCreated
```

### Step 3: Add to `@type t` spec under `:payload` (alphabetically sorted)

```elixir
payload:
  ...
  | %RefundCreated{}
  | %SettlementCreated{}
  ...
```

### Step 4: Add to `@types` keyword list (alphabetically sorted)

```elixir
@types [
  ...
  refund_created:       RefundCreated,
  settlement_created:   SettlementCreated,
  ...
]
```

### Step 5: Add to `@schema` discriminated union (alphabetically sorted)

```elixir
@schema Z.discriminated_union(:type, [
          ...
          Z.strict_map(%{type: Z.literal(:refund_created),       payload: RefundCreated.meta(:schema)})       |> Z.merge(@base),
          Z.strict_map(%{type: Z.literal(:settlement_created),   payload: SettlementCreated.meta(:schema)})   |> Z.merge(@base),
          ...
        ])
```

## Event Module Pattern

Events use the `Bifrost.Event.Notation` macro which provides:
- `defevent` macro for defining the schema
- Auto-generated struct with fields from schema
- `parse/1` and `parse!/1` functions
- `meta(:schema)` for accessing the Zot schema
- Jason.Encoder implementation

```elixir
defmodule Bifrost.Event.ExampleCreated do
  use Bifrost.Event.Notation

  defevent field_a: Zc.non_empty_string(),
           field_b: Zc.money(:cents),
           field_c: Z.optional(Zc.non_empty_string())
end
```

## Zot Validators

- `Z` - Alias for `Zot` (core validators)
- `Zc` - Alias for `Bifrost.Event.ZotCustom` (domain-specific validators)

Common custom validators in `Zc`:
- `non_empty_string()` - Trimmed, non-empty string
- `currency()` - ISO 4217 currency code
- `money(:cents | :units)` - Monetary amount
- `contact()` - Customer/merchant contact info
- `meta()` - Metadata map with string keys/values
- `percentage(:bps | :decimal)` - Percentage values

## Code Style

- Keep `@types` and `@schema` entries aligned with consistent spacing
- Sort all event references alphabetically
- Use module attributes for complex nested schemas (e.g., `@iban`, `@pix`, `@method`)
