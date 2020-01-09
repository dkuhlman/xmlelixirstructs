# Xmlelixirstructs

## Description

`Xmlelixirstructs` builds on top of `Sweetxml`.  `Sweetxml` is a layer on top of Xmerl.  `Xmlelixirstructs` converts the Xmerl
records in a parsed document produced by `Sweetxml` into Elixir
structs.

For information about `Sweetxml` see:
[Sweetxml](https://hexdocs.pm/sweet_xml/SweetXml.html).

You can find `Xmlelixirstructs` here:
[Xmlelixirstructs](https://github.com/dkuhlman/xmlelixirstructs).

Where to find stuff:

- The XML struct definitions are in `lib/xmlstructlib.ex`.  That
  file also contains functions (`convert_*`) that convert individual
  Xmerl record types.

- A variety of helper functions and utilities are in
  `lib/xmlstructlib.ex`.

One benefit of this capability is that tab completion on structs
works in `iex`.  For example, after parsing and converting an XML
document to Elixir structs, type "element." and then press TAB to
see a list of the fields in an element.


## Usage

Add `xmlelixirstructs` to your `mix` project by adding the following
to your `mix.exs` file under `deps`:

```elixir
def deps do
  [
    {:xmlelixirstructs, github: "dkuhlman/xmlelixirstructs"},
  ]
end
```


## Examples

Convert an XML document to Elixir structs:

```elixir
ex(4)> element = Xmlstruct.Utils.convert("path/to/xml/document.xml")
```

Convert an XML document in a string to Elixir structs:

```elixir
iex> text = File.read!("path/to/document.xml")
iex> element = Xmlstruct.Utils.convert_string(text)
iex> IO.puts(element.name)
```

Look in module `Xmlstruct.Utils` for additional helper functions.

In `iex`, you can type "h Xmlstruct.Utils.some_func" to get help on
most of the helper functions in `Xmlstruct.Utils`.

`Sweetxml` provides support for XPath.  `Xmlelixirstructs` does not.
You can work around this by using the capabilities of *both*
`Sweexml` and `Xmlelixirstructs`.  First create the `Sweetxml`
`Xmerl` record structure, then use `SweetXml.xpath` to search for an
element, and then convert it to Elixir `Struct` using
`Xmlelixirstructs`.  Here is an example:

```elixir
iex> rec = File.stream!("path/to/document.xml") |> SweetXml.parse
iex> rec1 = SweetXml.xpath(rec, ~x".//some-element-name")
iex> element = Xmlstruct.Utils.convert(rec1)
iex> IO.puts(element.name)
```

And another example:

```elixir
path = "path/to/document.xml"
pattern = ~x".//bbb|ddd"l
File.stream!(path)
|> SweetXml.parse
|> SweetXml.xpath(pattern)
|> Enum.map(&Xmlstruct.Utils.convert/1)
|> Enum.each(fn el -> IO.puts(el.name) end)
```

