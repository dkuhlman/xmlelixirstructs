defmodule Xmlattribute do
  require XmerlRecs
  def get_name(item), do: XmerlRecs.xmlAttribute(item, :name)
  def get_expanded_name(item), do: XmerlRecs.xmlAttribute(item, :expanded_name)
  def get_nsinfo(item), do: XmerlRecs.xmlAttribute(item, :nsinfo)
  def get_namespace(item), do: XmerlRecs.xmlAttribute(item, :namespace)
  def get_parents(item), do: XmerlRecs.xmlAttribute(item, :parents)
  def get_pos(item), do: XmerlRecs.xmlAttribute(item, :pos)
  def get_language(item), do: XmerlRecs.xmlAttribute(item, :language)
  def get_value(item), do: XmerlRecs.xmlAttribute(item, :value)
  def get_normalized(item), do: XmerlRecs.xmlAttribute(item, :normalized)
end

defmodule Xmlcomment do
  require XmerlRecs
  def get_parents(item), do: XmerlRecs.xmlComment(item, :parents)
  def get_pos(item), do: XmerlRecs.xmlComment(item, :pos)
  def get_language(item), do: XmerlRecs.xmlComment(item, :language)
  def get_value(item), do: XmerlRecs.xmlComment(item, :value)
end

defmodule Xmlelement do
  require XmerlRecs
  def get_name(item), do: XmerlRecs.xmlElement(item, :name)
  def get_expanded_name(item), do: XmerlRecs.xmlElement(item, :expanded_name)
  def get_nsinfo(item), do: XmerlRecs.xmlElement(item, :nsinfo)
  def get_namespace(item), do: XmerlRecs.xmlElement(item, :namespace)
  def get_parents(item), do: XmerlRecs.xmlElement(item, :parents)
  def get_pos(item), do: XmerlRecs.xmlElement(item, :pos)
  def get_attributes(item), do: XmerlRecs.xmlElement(item, :attributes)
  def get_content(item), do: XmerlRecs.xmlElement(item, :content)
  def get_language(item), do: XmerlRecs.xmlElement(item, :language)
  def get_xmlbase(item), do: XmerlRecs.xmlElement(item, :xmlbase)
  def get_elementdef(item), do: XmerlRecs.xmlElement(item, :elementdef)
end

defmodule Xmltext do
  require XmerlRecs
  def get_parents(item), do: XmerlRecs.xmlText(item, :parents)
  def get_pos(item), do: XmerlRecs.xmlText(item, :pos)
  def get_language(item), do: XmerlRecs.xmlText(item, :language)
  def get_value(item), do: XmerlRecs.xmlText(item, :value)
  def get_type(item), do: XmerlRecs.xmlText(item, :type)
end

