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

```
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

This example is a function that modifies items throughout an element
(Struct) tree:

```elixir
def test_modify(tree) do
  display_func = fn (new_tree, msg) ->
    IO.puts("---------------------------------")
    IO.puts("* #{msg}")
    IO.puts("---------------------------------")
    Xmlstruct.Utils.each(new_tree, fn item ->
      IO.puts("name: #{item.name}")
      Enum.each(item.attributes, fn attr ->
        IO.puts("    attribute -- name: #{attr.name}  value: #{attr.value}")
      end)
      Enum.each(item.content, fn child ->
        case child do
          %Xmlstruct.Text{} ->
            value = if is_list(child.value) do
              to_string(child.value)
            else
              child.value
            end
            if String.trim(value) !== "" do
              IO.puts("    text: \"#{value}\"")
            end
          _ -> :ok
        end
      end)
    end)
  end
  text_func = fn item -> %{item |
    value: String.upcase(to_string(item.value)),
  } end
  attribute_func = fn item ->
    name = if is_atom(item.name) do
      to_string(item.name)
    else
      item.name
    end
    value = if is_list(item.value) do
      to_string(item.value)
    else
      item.value
    end
    %{item |
    name: String.upcase(name),
    value: String.upcase(value),
  } end
  element_func = fn item ->
    name = if is_atom(item.name), do: Atom.to_string(item.name), else: item.name
    %{item | name: String.upcase(name) }
  end
  display_func.(tree, "Before")
  new_tree = Xmlstruct.Utils.map_tree(tree, element_func, attribute_func, text_func)
  display_func.(new_tree, "After")
  :ok
end
```
