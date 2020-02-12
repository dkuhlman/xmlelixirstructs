defmodule XmerlAccess do

  @moduledoc """
  Use Elixir meta-programming to generate test and accessor functions.

  For each Xmerl record type generate the following:

  - A test function, e.g. `is_element/1`, `is_attribute/1`, etc.

  - A set of assessor functions, one for each field, e.g. `get_element_name/1`,
    `get_element_attributes/1`, ..., `get_attribute_name/1`, etc.

  """

  require XmerlRecs

  @record_types ["element", "attribute", "text", "namespace", "comment"]

  @record_types
  |> Enum.each(fn record_type_str ->
    record_type_string = "xml#{String.capitalize(record_type_str)}"
    record_type_atom = String.to_atom(record_type_string)
    is_method_name_str = "is_#{record_type_str}"
    is_method_name_atom = String.to_atom(is_method_name_str)
    is_method_body_str = """
      if is_tuple(item) and tuple_size(item) > 0 do
        case elem(item, 0) do
          :#{record_type_string} -> true
          _ -> false
        end
      else
        false
      end
    """
    {:ok, is_method_body_ast} = Code.string_to_quoted(is_method_body_str)
    def unquote(is_method_name_atom) (item) do
      unquote(is_method_body_ast)
    end
    Record.extract(record_type_atom, from_lib: "xmerl/include/xmerl.hrl")
    |> Enum.each(fn {field_name_atom, _} ->
      method_name_str = "get_#{record_type_str}_#{to_string(field_name_atom)}"
      method_name_atom = String.to_atom(method_name_str)
      method_body_str = "XmerlRecs.#{to_string(record_type_atom)}(item, :#{to_string(field_name_atom)})"
      {:ok, method_body_ast} = Code.string_to_quoted(method_body_str)
      def unquote(method_name_atom)(item) do
        unquote(method_body_ast)
      end
    end)
  end)

end

defmodule TestMetaprogramming do
  @moduledoc """
  Test functions for metaprogramming generated Xmerl access functions
  """

  require XmerlAccess
  require XmerlRecs

  @doc """
  Walk and show the tree of XML elements.

  ## Examples
  
      iex> rec = File.stream!("Data/test02.xml") |> SweetXml.parse
      iex> Test22.show_tree(rec)

  """
  @spec show_tree(Tuple.t(), String.t()) :: nil
  def show_tree(rec, init_filler \\ "", add_filler \\ "    ") do
    IO.puts("#{init_filler}element name: #{XmerlAccess.get_element_name(rec)}")
    Enum.each(XmerlAccess.get_element_attributes(rec), fn attr ->
      name = XmerlAccess.get_attribute_name(attr)
      value = XmerlAccess.get_attribute_value(attr)
      IO.puts("#{init_filler}    attribute -- name: #{name}  value: #{value}")
    end)
    Enum.each(XmerlAccess.get_element_content(rec), fn item ->
      filler1 = init_filler <> add_filler
      case elem(item, 0) do
        :xmlElement ->
          show_tree(item, filler1, add_filler)
          nil
        _ -> nil
      end
    end)
    nil
  end

  @doc """
  Show some infomation in the element tree using Elixir Xmerl records.

  ## Examples

      iex> record = File.stream!("path/to/my/doc.xml") |> SweetXml.parse
      iex> TestMetaprogramming.demo1 record

  """
  @spec demo1(Tuple.t()) :: :ok
  def demo1 element do
    name = XmerlRecs.xmlElement(element, :name)
    IO.puts("element name: #{name}")
    XmerlRecs.xmlElement(element, :attributes)
    |> Enum.each(fn attr ->
      attrname = XmerlRecs.xmlAttribute(attr, :name)
      attrvalue = XmerlRecs.xmlAttribute(attr, :value)
      IO.puts("    attribute -- name: #{attrname}  value: #{attrvalue}")
    end)
    XmerlRecs.xmlElement(element, :content)
    |> Enum.each(fn item ->
      case elem(item, 0) do
        :xmlText ->
          IO.puts("    text -- value: #{XmerlRecs.xmlText(item, :value)}")
        _ -> nil
      end
    end)
  end

  @doc """
  Show some infomation in element tree using functions created with meta-programming.

  ## Examples

      iex> record = File.stream!("path/to/my/doc.xml") |> SweetXml.parse
      iex> TestMetaprogramming.demo2 record

  """
  @spec demo2(Tuple.t()) :: :ok
  def demo2 element do
    name = Xml.Element.get_name(element)
    IO.puts("element name: #{name}")
    Xml.Element.get_attributes(element)
    |> Enum.each(fn attr ->
      attrname = XmerlRecs.xmlAttribute(attr, :name)
      attrvalue = XmerlRecs.xmlAttribute(attr, :value)
      IO.puts("    attribute -- name: #{attrname}  value: #{attrvalue}")
    end)
    Xml.Element.get_content(element)
    |> Enum.each(fn item ->
      case elem(item, 0) do
        :xmlText ->
          IO.puts("    text -- value: #{Xml.Text.get_value(item)}")
        _ -> nil
      end
    end)
  end

end
