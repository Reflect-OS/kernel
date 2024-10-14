defmodule ReflectOS.Kernel.Settings.SectionStore do
  @moduledoc false

  # Store for sections and their associated configuration.
  # Should not need to be access or used by those extending ReflectOS

  alias ReflectOS.Kernel.Settings
  alias ReflectOS.Kernel.Section

  def list() do
    Settings.match(["sections", :_])
    |> Enum.map(fn {["sections", id], section} ->
      %{section | id: id}
    end)
  end

  def get(section_id) when is_binary(section_id) do
    case Settings.get(["sections", section_id]) do
      %Section{module: module, config: config} = section ->
        %{section | id: section_id, config: struct(module, config)}

      nil ->
        nil
    end
  end

  def subscribe(section_id) when is_binary(section_id) do
    Settings.subscribe(["sections", section_id])
  end

  def save(%Section{id: nil} = section) do
    section = %{section | id: UUID.uuid1()}
    save(section)
  end

  def save(%Section{id: id, config: config} = section)
      when is_binary(id) do
    formatted =
      if Map.has_key?(config, :__struct__) do
        %{section | config: Map.from_struct(config)}
      else
        section
      end

    case Settings.put(["sections", id], formatted) do
      :ok ->
        {:ok, section}

      error ->
        error
    end
  end

  def delete(section_id)
      when is_binary(section_id) do
    Settings.delete(["sections", section_id])
  end
end
