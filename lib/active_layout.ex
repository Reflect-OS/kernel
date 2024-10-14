defmodule ReflectOS.Kernel.ActiveLayout do
  alias ReflectOS.Kernel.Settings.LayoutStore

  @table ReflectOS.ActiveLayout

  @key ["active_layout"]

  def get() do
    case PropertyTable.get(@table, @key) do
      nil ->
        nil

      layout_id ->
        LayoutStore.get(layout_id)
    end
  end

  def put(layout_id) when is_binary(layout_id) do
    PropertyTable.put(@table, @key, layout_id)
  end

  def subscribe() do
    PropertyTable.subscribe(@table, @key)
  end
end
