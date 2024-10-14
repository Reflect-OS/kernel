defmodule ReflectOS.Kernel.Settings.LayoutStore do
  @moduledoc false

  # Store for layouts and their associated configuration.
  # Should not need to be access or used by those extending ReflectOS

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings

  def list() do
    Settings.match(["layouts", :_])
    |> Enum.map(fn {["layouts", id], layout} ->
      %{layout | id: id}
    end)
  end

  def get(layout_id) when is_binary(layout_id) do
    case Settings.get(["layouts", layout_id]) do
      %Layout{module: module, config: config} = layout ->
        %{layout | id: layout_id, config: struct(module, config)}

      nil ->
        nil
    end
  end

  def subscribe(layout_id) when is_binary(layout_id) do
    Settings.subscribe(["layouts", layout_id])
  end

  def save(%Layout{id: nil} = layout) do
    layout = %{layout | id: UUID.uuid1()}
    save(layout)
  end

  def save(%Layout{id: id, config: config} = layout)
      when is_binary(id) do
    formatted =
      if Map.has_key?(config, :__struct__) do
        %{layout | config: Map.from_struct(config)}
      else
        layout
      end

    case Settings.put(["layouts", id], formatted) do
      :ok ->
        {:ok, layout}

      error ->
        error
    end
  end

  def delete(layout_id)
      when is_binary(layout_id) do
    Settings.delete(["layouts", layout_id])
  end
end
