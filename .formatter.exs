[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  excludes: [
    "lib/bifrost/event.ex"
  ],
  subdirectories: [],
  plugins: [],
  import_deps: [],
  line_length: 140,
  locals_without_parens: [
    defevent: 1,
    defstructz: 1
  ],
  export: [
    locals_without_parens: [
      defevent: 1
    ]
  ]
]
