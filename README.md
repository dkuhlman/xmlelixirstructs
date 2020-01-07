# Xmlstructs

## Description

`xmlstructs` builds on top of `sweetxml`.  It converts the Xmerl
records in a parsed document produced by `sweetxml` into Elixir
structs.

- The XML struct definitions are in `lib/xmlstructlib.ex`.

- A variety of helper functions and utilities are in
  `lib/xmlstructlib.ex`.


## Usage

Add `xmlelixirstructs` to your `mix` project by adding the following
to your `mix.exs` file under `deps`:

```elixir
def deps do
  [
    {:xmlelixirstructs, github: "dkuhlman/xmlelixirstructs"},
  ]
end


Convert an XML document to Elixir structs:

```elixir
ex(4)> element = Xmlstruct.Utils.convert("path/to/xml/document.xml")


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xmlstructs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xmlelixirstructs, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xmlstructs](https://hexdocs.pm/xmlstructs).

