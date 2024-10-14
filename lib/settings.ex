defmodule ReflectOS.Kernel.Settings do
  @moduledoc false

  # Root functionality for other settings

  @table ReflectOS.Settings

  def get(key, default \\ nil) when is_list(key) do
    PropertyTable.get(@table, key, default)
  end

  def match(pattern) do
    PropertyTable.match(@table, pattern)
  end

  def put(key, value) when is_list(key) do
    PropertyTable.put(@table, key, value)
    PropertyTable.flush_to_disk(@table)
  end

  def put_many(properties) when is_list(properties) do
    PropertyTable.put_many(@table, properties)
    PropertyTable.flush_to_disk(@table)
  end

  def subscribe(key) when is_list(key) do
    PropertyTable.subscribe(@table, key)
  end

  def delete(key) when is_list(key) do
    PropertyTable.delete(@table, key)
    PropertyTable.flush_to_disk(@table)
  end
end
