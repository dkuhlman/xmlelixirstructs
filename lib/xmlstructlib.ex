defmodule XmerlRecs do
  @moduledoc """
  Define Xmerl records using record definitions extracted from Erlang Xmerl.
  """

  require Record
  Record.defrecord(:xmlElement, Record.extract(:xmlElement,
    from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText,
    from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute,
    from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlNamespace, Record.extract(:xmlNamespace,
    from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlComment, Record.extract(:xmlComment,
    from_lib: "xmerl/include/xmerl.hrl"))

end

defmodule Xmlstruct.Namespace do
  @moduledoc """
  """
  defstruct [
    default: [],
    nodes: [],
  ]
end

defmodule Xmlstruct.Element do
  @moduledoc """
  The Elixir Struct equivalent of an Xmerl :xmlElement record.
  """
  defstruct [
    name: "",                   # atom()
    expanded_name: [],          # string() | {URI,Local} | {"xmlns",Local}
    nsinfo: [],                 # {Prefix, Local} | []
    namespace: %Xmlstruct.Namespace{},
    parents: [],                # [{atom(),integer()}]
    pos: -1,                    # integer()
    attributes: [],             # [%XmlAttribut{}]
    content: [],
    language: "",               # string()
    xmlbase: "",                # string() XML Base path, for relative URI:s
    elementdef: :undeclared,    # atom(), one of [undeclared | prolog | external | element]
  ]
end

defmodule Xmlstruct.Attribute do
  @moduledoc """
  The Elixir Struct equivalent of an Xmerl :xmlAttribute record.
  """
  defstruct [
    name: nil,                  # atom()
    expanded_name: nil,         # atom() | {string(),atom()}
    nsinfo: [],                 # {Prefix, Local} | []
    namespace: [],              # inherits the element's namespace
    parents: [],                # [{atom(),integer()}]
    pos: -1,                    # integer()
    language: [],               # inherits the element's language
    value: "",                  # Binary | atom() | integer()
    normalized: nil,            # Boolean
  ]
end

defmodule Xmlstruct.Decl do
  @moduledoc """
  """
  defstruct [
    vsn: "",                    # string() XML version
    encoding: "",               # string() Character encoding 
    standalone: nil,            # (yes | no)
    attributes: nil,            # [#xmlAttribute()] Other attributes than above
      ]
end

defmodule Xmlstruct.Namespacerecord do
  @moduledoc """
  """
  defstruct [
    default: [],
    nodes: [],
  ]
  end

## namespace node - i.e. a {Prefix, URI} pair
defmodule Xmlstruct.Namespacenode do
  @moduledoc """
  """
  defstruct [
    parents: [],                # [{atom(),integer()}]
    pos: -1,                    # integer
    prefix: "",                 # string()
    uri: [],                    # [] | atom()
  ]
end

defmodule Xmlstruct.Text do
  @moduledoc """
  The Elixir Struct equivalent of an Xmerl :xmlText record.

  plain text
  IOlist = [char() | binary () | IOlist]
  """
  defstruct [
    parents: [],                # [{atom(),integer()}]
    pos: -1,                    # integer()
    language: [],               # inherits the element's language
    value: "",                  # IOlist()
    type: :text,                # atom() one of (text|cdata)
  ]
end

defmodule Xmlstruct.Comment do
  @moduledoc """
  plain text
  """
  defstruct [
    parents: [],                # [{atom(),integer()}]
    pos: -1,                    # integer()
    language: [],               # inherits the element's language
    value: "",                  # IOlist()
  ]
end

defmodule Xmlstruct.XmerlToStructConversions do
  @moduledoc """
  Functions for converting Erlang Xmerl tuples to Elixir structs.

  ## Examples

      iex> File.stream!("path/to/document.xml") |> SweetXml.parse |> Xmlstruct.Utils.convert_to_struct

      iex> Xmlstruct.Utils.convert_to_struct("path/to/document.xml")

  """

  require XmerlRecs
  require Xmlstruct.Element

  def convert_attribute(attr) do
    attr = %Xmlstruct.Attribute{
      name: XmerlRecs.xmlAttribute(attr, :name),
      expanded_name: XmerlRecs.xmlAttribute(attr, :expanded_name),
      nsinfo: XmerlRecs.xmlAttribute(attr, :nsinfo),
      namespace: XmerlRecs.xmlAttribute(attr, :namespace),
      parents: XmerlRecs.xmlAttribute(attr, :parents),
      pos: XmerlRecs.xmlAttribute(attr, :pos),
      language: XmerlRecs.xmlAttribute(attr, :language),
      value: XmerlRecs.xmlAttribute(attr, :value),
      normalized: XmerlRecs.xmlAttribute(attr, :normalized),
    }
    attr
  end

  def convert_comment(item) do
    %Xmlstruct.Comment{
      parents: XmerlRecs.xmlComment(item, :parents),
      pos: XmerlRecs.xmlComment(item, :pos),
      language: XmerlRecs.xmlComment(item, :language),
      value: XmerlRecs.xmlComment(item, :value),
    }
  end

  def convert_element(element) do
    elstruct = %Xmlstruct.Element{
      name: XmerlRecs.xmlElement(element, :name),
      expanded_name: XmerlRecs.xmlElement(element, :expanded_name),
      nsinfo: XmerlRecs.xmlElement(element, :nsinfo),
      namespace: convert_namespace(XmerlRecs.xmlElement(element, :namespace)),
      parents: XmerlRecs.xmlElement(element, :parents),
      pos: XmerlRecs.xmlElement(element, :pos),
      attributes: Enum.map(
        XmerlRecs.xmlElement(element, :attributes),
        fn (item) -> convert_attribute(item) end
      ),
      content: convert_element_content(
        XmerlRecs.xmlElement(element, :content)
      ),
      language: XmerlRecs.xmlElement(element, :language),
      xmlbase: XmerlRecs.xmlElement(element, :xmlbase),
      elementdef: XmerlRecs.xmlElement(element, :elementdef),
    }
    elstruct
  end

  def convert_element_content(content) do
    converted_content = Enum.map(content, fn (item) ->
      key = elem(item, 0)
      case key do
        :xmlText ->
          convert_text(item)
        :xmlElement ->
          convert_element(item)
        :xmlComment ->
          convert_comment(item)
        _ -> :error
      end
    end)
    converted_content
  end

  def convert_namespace(item) do
    namespace = %Xmlstruct.Namespace{
      default: XmerlRecs.xmlNamespace(item, :default),
      nodes: XmerlRecs.xmlNamespace(item, :nodes),
    }
    namespace
  end

  def convert_text(item) do
    text = %Xmlstruct.Text{
      parents: XmerlRecs.xmlText(item, :parents),
      pos: XmerlRecs.xmlText(item, :pos),
      language: XmerlRecs.xmlText(item, :language),
      value: XmerlRecs.xmlText(item, :value),
      type: XmerlRecs.xmlText(item, :type),
    }
    text
  end

end

defmodule Xmlstruct.StructToXmerlConversions do
  @moduledoc """
  Functions for converting Elixir structs to Erlang Xmerl tuples.
  """

  def convert_attribute(attr) do
    attr_rec = {
      :xmlAttribute,
      attr.name,
      attr.expanded_name,
      attr.nsinfo,
      attr.namespace,
      attr.parents,
      attr.pos,
      attr.language,
      attr.value,
      attr.normalized,
    }
    attr_rec
  end

  def convert_comment(item) do
    {
      :xmlComment,
      item.parents,
      item.pos,
      item.language,
      item.value,
    }
  end

  def convert_element(item) do
    {
      :xmlElement,
      item.name,
      item.expanded_name,
      item.nsinfo,
      convert_namespace(item.namespace),
      item.parents,
      item.pos,
      Enum.map(item.attributes, fn attr ->
        convert_attribute(attr)
      end),
      convert_element_content(item.content),
      item.language,
      item.xmlbase,
      item.elementdef,
    }
  end

  def convert_element_content(items) do
    Enum.map(items, fn item ->
      case item do
        %Xmlstruct.Text{} ->
          convert_text(item)
        %Xmlstruct.Element{} ->
          convert_element(item)
        %Xmlstruct.Comment{} ->
          convert_comment(item)
      end
    end)
  end

  def convert_namespace(item) do
    {
      :xmlNamespace,
      item.default,
      item.nodes,
    }
  end

  def convert_text(item) do
    {
      :xmlText,
      item.parents,
      item.pos,
      item.language,
      item.value,
      item.type,
    }
  end


end

defmodule Xmlstruct.Utils do
  @moduledoc """
  Utility and helper funtions for converting Xmerl records to Elixir structs.

  Public functions:

  - `convert_to_struct(path)` -- Convert an XML document/file to Elixir struct.
    to an Elixir struct.

  - `convert_to_struct(xmerl_rec)` -- Convert an element tree created by SweetXml.parse
    to an Elixir struct.

  - `convert_string_to_struct` -- Convert XML string to Elixir struct.

  - `get_xmerl_tree` -- Create the Xmerl tree from an XML file using SweetXml.

  - `show_content` -- Show the content of the top level element in
    an element tree.

  - `show_element_tree` -- Write the tags (names) of the elements in
    an element tree to stdout or a file.

  - `write_element_tree_to_file` -- Write the tags (names) of the
    elements in an element tree to a file.

  - `tree_to_stream` -- Create a stream of all the elements in a tree.

  - `tree_to_list` -- Create a list of all the elements in a tree.

  - `elements_from_content` -- Select and return all the elements
    (children) in the top level content of an element.

  - `each` -- Iterate of all elements in element tree.  Call a
    function on each element.

  - `reduce` -- Invoke `func(element, acc)` on each element in an element tree.

  """

  @doc """
  Convert an element tree created by SweetXml.parse to an Elixir struct.

  If already converted, return it unchanged.

  ## Examples

      File.stream!("path/to/doc.xml") |> SweetXml.parse() |> Xml.Struct.convert()

      Xml.Struct.convert("path/to/doc.xml")


  """
  @spec convert_to_struct(Map.t()) :: Map.t()
  def convert_to_struct(obj) when is_map(obj) do
    obj
  end
  @spec convert_to_struct(String.t()) :: Map.t()
  def convert_to_struct(path) when is_binary(path) do
    #File.stream!(path) |> SweetXml.parse() |> convert_to_struct()
    get_xmerl_tree(path) |> convert_to_struct()
  end
  @spec convert_to_struct(Tuple.t()) :: Map.t()
  def convert_to_struct(tree) do
    key = elem(tree, 0)
    case key do
      :xmlElement ->
        Xmlstruct.XmerlToStructConversions.convert_element(tree)
      :xmlAttribute ->
        Xmlstruct.XmerlToStructConversions.convert_attribute(tree)
      _ ->
        {:error, "Not an Xmerl record/tuple"}
    end
  end

  @doc """
  Convert XML to structs, given the XML content in a binary string.

  ## Examples

      iex> text = File.read!("path/to/document.xml")
      iex> element = Xmlstruct.Utils.convert_string_to_struct(text)
      iex> IO.puts(element.name)
  
  """
  @spec convert_string_to_struct(String.t()) :: Map.t()
  def convert_string_to_struct(text) do
    text |> SweetXml.parse() |> convert_to_struct()
  end

  @doc """
  Find and return a nested tuple (a tree) of elements.
  These tuples are the Xmerl data structures.

  ## Examples

      rec = Xmlstruct.Utils.get_xmerl_tree("path/to/doc.xml")
      element_recs = SweetXml.xpath(rec, ~x".//tag-name"l)

  """
  @spec get_xmerl_tree(String.t()) :: Tuple.t()
  def get_xmerl_tree(file_path) when is_binary(file_path) do
    tree = File.stream!(file_path) |> SweetXml.parse()
    tree
  end

#  @doc """
#  Convert an element struct tree to an xmerl record.
#
#  ## Examples
#
#  """
#  @spec convert_to_xmerlrec(Map.t()) :: Tuple.t()
#  def convert_to_xmerlrec(element) do
#    record = StructToXmerlConversions.convert_element(element)
#    record
#  end

  @doc """
  Show the content of the top level element in an element tree.

  ## Examples
  
      iex> Xmlstruct.Utils.show_content(element)

  """
  def show_content(tree) do
    tree.content
    |> Enum.each(fn item ->
      case item do
        %Xmlstruct.Element{} ->
          IO.puts("element -- name: #{item.name}")
        %Xmlstruct.Text{} ->
          value = List.to_string(item.value)
          if not String.match?(value, ~r/^[ \n\t]*$/) do
            IO.puts("text -- value: #{value}")
          end
        _ -> nil
      end
    end)
  end

  @doc """
  Write the tags (names) of the elements in an element tree to stdout or a file.

  Use indentation (level) to show nesting of elements.

  ## Examples

      iex> Xmlstruct.Utils.show_element_tree(element)

      iex> {:ok, file} = File.open("tmp.txt", [:write])
      iex> func = fn (line) -> IO.write(file, line <> "\\n") end
      iex> Xmlstruct.Utils.show_element_tree(element, "", func)
      iex> File.close(file)

  """
  def show_element_tree(el, level \\ "", wrt \\ &IO.puts/1) do
    wrt.("#{level}name: #{el.name}")
    Enum.each(el.content, fn (item) ->
      case item do
        %Xmlstruct.Element{} ->
          show_element_tree(item, level <> "    ", wrt)
        _ -> nil
      end
    end)
  end

  @doc """
  Write the tags (names) of the elements in an element tree to a file.

  ## Examples

      iex> Xmlstruct.Utils.write_element_tree_to_file("out.txt", element)

  """
  def write_element_tree_to_file(path, el) do
    {:ok, device} = File.open(path, [:write])
    IO.inspect(device, label: "device")
    writer = fn (item) -> IO.write(device, item <> "\n") end
    show_element_tree(el, "", writer)
    File.close(device)
  end

  @doc """
  Create a stream of all the elements in a tree.

  ## Examples

      iex> stream = Xmlstruct.Utils.tree_to_stream(element)
      iex> stream |> Enum.each(fn el -> IO.puts("element name: \#{el.name}") end)

  """
  def tree_to_stream(element) do
    tree_to_stream_helper([element])
  end
  defp tree_to_stream_helper(elements) when is_list(elements) do
    Stream.resource(
      fn -> elements end,
      &process_element/1,
      fn _ -> nil end
    )
  end

  defp process_element([]) do
    {:halt, nil}
  end
  defp process_element(elements) do
    children1 = Enum.map(elements, fn (el) ->
      elements_from_content(el)
    end)
    children2 = List.flatten(children1)
    {elements, children2}
  end

  @doc """
  Select and return all the elements (children) in the top level content
  of an element.

  ## Examples
  
      iex> list_of_elements = elements_from_content(element)

  """
  def elements_from_content(el) do
    Enum.filter(el.content, fn
      %Xmlstruct.Element{} -> true
      _ -> false
    end)
  end

  @doc """
  Create a list of all the elements in a tree.

  ## Examples

      iex> list = Xmlstruct.Utils.tree_to_list(element)
      iex> list |> Enum.each(fn el -> IO.puts("element name: \#{el.name}") end)

  """
  def tree_to_list(element) do
    acc = tree_to_list(element, [])
    Enum.reverse(acc)
  end
  def tree_to_list(element, acc) do
    list_to_list(elements_from_content(element), [element | acc])
  end

  def list_to_list([], acc), do: acc
  def list_to_list([el | rest], acc) do
    list_to_list(rest, tree_to_list(el, acc))
  end

  @doc """
  Invoke `func(element, acc)` on each element in an element tree.

  Function `func` should take two arguments: an `Xmlstruct.Element`
  and an accumulator, and should return an updated accumulator.  The
  initial value of the accumulator is `acc`.

  ## Examples

      iex> # count elements
      iex> root_element |> Xmlstruct.Utils.reduce(0, fn (_, acc) -> acc + 1 end)
      iex> # count attributes
      iex> Xmlstruct.Utils.reduce(root, 0, fn (el, acc) -> acc + length(el.attributes) end)

  """
  @spec reduce(Map.t(), any(), (Map.t(), any() -> any())) :: any()
  def reduce(element, acc, func) do
    reduce_aux([element], acc, func)
  end

  defp reduce_aux([], acc, _func), do: acc
  defp reduce_aux([element | elements], acc, func) do
    acc1 = func.(element, acc)
    acc2 = reduce_aux(
      Xmlstruct.Utils.elements_from_content(element), acc1, func)
    reduce_aux(elements, acc2, func)
  end

  @doc """
  Walk the element tree and invoke `func(element)` on each element.

  Function `func` should take a single argument: an `Xmlstruct.Element`.

  ## Examples

      iex> root_element |> Xmlstruct.Utils.reduce(0, fn (el) -> IO.puts(el.name) end)

  """
  @spec walk_tree(Map.t(), (Map.t() -> any())) :: :ok
  def walk_tree(element, func) do
    walk_tree_aux([element], func)
  end

  defp walk_tree_aux([], _func), do: :ok
  defp walk_tree_aux([element | elements], func) do
    func.(element)
    walk_tree_aux(
      Xmlstruct.Utils.elements_from_content(element), func)
    walk_tree_aux(elements, func)
  end

  @doc """
  Iterate of all elements in element tree.  Call a function on each element.

  ## Examples

      root_element = Xmlstruct.Utils.Test.test01("Data/test02.xml")
      Xmlstruct.Utils.each(root_element, fn el ->
        IO.puts("----\\nelement: \#{el.name}")
        el.attributes
        |> Enum.each(
          fn attr ->
            IO.puts("name: \#{attr.name}  value: \#{attr.value}")
          end)
      end)

  """
  @spec each(Map.t(), (Map.t() -> any())) :: :ok
  def each(element, func) do
    strm = tree_to_stream(element)
    Enum.each(strm, func)
  end

end

defmodule Xmlstruct.Test do

  @doc """
  Print the tags (names) of all the elements in an XML file.

  ## Examples

      iex> Xmlstruct.Test.print_all_tags "path/to/document.xml"

  """
  def print_all_tags(path) do
    element = Xmlstruct.Utils.convert_to_struct(path)
    Xmlstruct.Utils.each(element, fn (el) ->
      IO.puts("tag: #{el.name}") end)
    #element
  end

end
