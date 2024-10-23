defmodule ReflectOS.Kernel.LayoutManager.Changeset do
  @moduledoc false

  # Internal changeset for creating/updating Layout Managers themselves (not their configuration).

  import Ecto.Changeset

  alias ReflectOS.Kernel.LayoutManager

  @types %{
    id: :string,
    name: :string,
    module: ReflectOS.Kernel.Ecto.Module,
    config: :map
  }

  def change(%LayoutManager{} = layout_manager, params \\ %{}) do
    {layout_manager, @types}
    |> cast(params, [:name, :module, :config])
    |> validate_required([:name, :module])
    |> validate_length(:name, min: 3)
  end
end
