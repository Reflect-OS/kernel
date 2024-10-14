defmodule ReflectOS.Kernel.Section.Changeset do
  @moduledoc false

  # Internal changeset for creating/updating sections themselves (not their configuration).

  import Ecto.Changeset

  alias ReflectOS.Kernel.Section

  @types %{
    id: :string,
    name: :string,
    module: ReflectOS.Kernel.Ecto.Module,
    config: :map
  }

  def change(%Section{} = section, params \\ %{}) do
    {section, @types}
    |> cast(params, [:name, :module, :config])
    |> validate_required([:name, :module])
    |> validate_length(:name, min: 3)
  end
end
