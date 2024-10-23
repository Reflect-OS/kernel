defmodule ReflectOS.Kernel.Layout.Changeset do
  @moduledoc false

  # Internal changeset for creating/updating layouts themselves (not their configuration).
  import Ecto.Changeset

  alias ReflectOS.Kernel.Layout

  @types %{
    id: :string,
    name: :string,
    module: ReflectOS.Kernel.Ecto.Module,
    config: :map,
    sections: :map
  }

  def change(%Layout{} = section, params \\ %{}) do
    {section, @types}
    |> cast(params, [:name, :module, :config, :sections])
    |> validate_required([:name, :module])
    |> validate_length(:name, min: 3)
  end
end
