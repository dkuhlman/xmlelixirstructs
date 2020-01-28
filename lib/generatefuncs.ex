defmodule GenerateFuncs do

  @moduledoc """
  This module can be used to generate an Elixir (.ex) file containing Xmerl accessor functions.
  """

  @type device :: atom | pid

  @type_names [:attribute, :comment, :element, :text, ]

  @doc """
  Write out source code for accessor functions for Xmerl records.

  **Caution:** This function is destructive.  It will over-write an
  existing file without warning.

  ## Examples

      iex> GenerateFuncs.generate("path/to/output/file.ex")

  """
  @spec generate(Path.t()) :: :ok
  def generate(path) when is_binary(path) do
    {:ok, dev} = File.open(path, [:write])
    wrt = fn val -> IO.write(dev, val <> "\n") end
    generate(wrt)
    :ok
  end
  @spec generate(device) :: :ok
  def generate(wrt) do
    #wrt = &IO.putss/1
    @type_names
    |> Enum.each(fn item ->
      name = to_string(item)
      cap_name = String.capitalize(name)
      #ident = to_atom("xml#{String.capitalize(to_string(item))}")
      wrt.("defmodule Xml#{name} do")
      wrt.("  require XmerlRecs")
      
      Record.extract(
        String.to_atom("xml#{cap_name}"),
        from_lib: "xmerl/include/xmerl.hrl")
      #|> IO.inspect(label: "fields")
      |> Enum.each(fn {field, _} ->
        wrt.("  def get_#{field}(item), do: XmerlRecs.xml#{cap_name}(item, :#{field})")
      end)
      wrt.("end\n")
    end)
  end

end
