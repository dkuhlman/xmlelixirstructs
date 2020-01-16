# XmlElixirStructs

## Description

`XmlElixirStructs` builds on top of `SweetXml`.  `SweetXml` is a layer on top of Xmerl.  `XmlElixirStructs` converts the Xmerl
records in a parsed document produced by `SweetXml` into Elixir
structs.

For information about `SweetXml` see:
[SweetXml](https://hexdocs.pm/sweet_xml/SweetXml.html).

You can find `XmlElixirStructs` here:
[XmlElixirStructs](https://github.com/dkuhlman/xmlelixirstructs).

One benefit of this capability is that tab completion on structs
works in `iex`.  For example, after parsing and converting an XML
document to Elixir structs and capturing the root element in
variable `root`, type "root." and then press TAB to
see a list of the fields in that element.


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

Where to find stuff:

- The XML struct definitions are in `lib/xmlstructlib.ex`.  That
  file also contains functions (`convert_*`) that convert individual
  Xmerl record types.

- A variety of helper functions and utilities are in module
  `Xmlstruct.Utils` in `lib/xmlstructlib.ex`.

The following will show you a list of helper functions:

```elixir
iex> h Xmlstruct.Utils.reduce
```


## Examples

Convert an XML document to Elixir structs:

```elixir
iex> element = Xmlstruct.Utils.convert("path/to/xml/document.xml")
```

Convert an XML document in a string to Elixir structs:

```elixir
iex> text = File.read!("path/to/document.xml")
iex> element = Xmlstruct.Utils.convert_string(text)
iex> IO.puts(element.name)
```

Print out the names (tags) of each of the elements in a document:

```elixir
iex> element = Xmlstruct.Utils.convert("path/to/xml/document.xml")
iex> element |> Xmlstruct.Utils.each(fn el -> IO.puts(el.name) end)
```

Serialize (export) an XML structure tree to a charlist:

```elixir
iex> characters = Xmlstruct.Utils.export_struct(root_element)
iex> IO.puts(characters)
```

Look in module `Xmlstruct.Utils` for additional helper functions.

In `iex`, you can type "h Xmlstruct.Utils.some_func" to get help on
most of the helper functions in `Xmlstruct.Utils`.

`SweetXml` provides support for XPath.  `XmlElixirStructs` does not.
You can work around this by using the capabilities of *both*
`SweetXml` and `XmlElixirStructs`.  First create the `SweetXml`
`Xmerl` record structure, then use `SweetXml.xpath` to search for an
element, and then convert that Xmerl record to an Elixir `Struct` using
`XmlElixirStructs`.  Here is an example:

```elixir
iex> import SweetXml
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

