defmodule ReflectOS.Kernel.Settings.LayoutManagerStore do
  @moduledoc false

  # Store for layout managers and their associated configuration.
  # Should not need to be access or used by those extending ReflectOS

  alias ReflectOS.Kernel.Settings
  alias ReflectOS.Kernel.LayoutManager

  def list() do
    Settings.match(["layout_managers", :_])
    |> Enum.map(fn {["layout_managers", id], layout_manager} ->
      format(layout_manager, id)
    end)
  end

  def get(layout_manager_id) when is_binary(layout_manager_id) do
    case Settings.get(["layout_managers", layout_manager_id]) do
      %LayoutManager{} = layout_manager ->
        format(layout_manager, layout_manager_id)

      nil ->
        nil
    end
  end

  def subscribe(layout_manager_id) when is_binary(layout_manager_id) do
    Settings.subscribe(["layout_managers", layout_manager_id])
  end

  def save(%LayoutManager{id: nil} = layout_manager) do
    layout_manager = %{layout_manager | id: UUID.uuid1()}
    save(layout_manager)
  end

  def save(%LayoutManager{id: id, config: config} = layout_manager)
      when is_binary(id) do
    formatted =
      if Map.has_key?(config, :__struct__) do
        %{layout_manager | config: Map.from_struct(config)}
      else
        layout_manager
      end

    case Settings.put(["layout_managers", id], formatted) do
      :ok ->
        {:ok, layout_manager}

      error ->
        error
    end
  end

  def delete(layout_manager_id)
      when is_binary(layout_manager_id) do
    Settings.delete(["layout_managers", layout_manager_id])
  end

  defp format(%LayoutManager{module: module, config: config} = layout_manager, layout_manager_id) do
    %{layout_manager | id: layout_manager_id, config: struct(module, config)}
  end
end
