[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: [],
  excludes: [
    "lib/bifrost/event.ex",
    "lib/bifrost/inbox.ex",
    "lib/bifrost/outbox.ex"
  ],
  import_deps: [:ecto],
  plugins: [],
  line_length: 140,
  locals_without_parens: [
    defevent: 1
  ]
]
