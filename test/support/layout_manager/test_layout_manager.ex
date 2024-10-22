defmodule ReflectOS.Kernel.TestLayoutManager do
  use ReflectOS.Kernel.LayoutManager

  alias ReflectOS.Kernel.Option
  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.LayoutManager.Definition
  alias ReflectOS.Kernel.LayoutManager.State

  @impl true
  def layout_manager_definition() do
    %Definition{
      name: "Test Layout Manager",
      icon: "test-icon"
    }
  end

  embedded_schema do
    field(:layout, :string)
  end

  @impl true
  def changeset(%__MODULE__{} = layout_manager, params \\ %{}) do
    layout_manager
    |> cast(params, [:layout])
    |> validate_required([:layout])
  end

  @impl true
  def layout_manager_options(),
    do: [
      %Option{
        key: :layout,
        label: "Layout",
        config: %{
          type: "select",
          options: []
        }
      }
    ]

  @impl LayoutManager
  def init_layout_manager(%State{} = state, %{layout: layout_id}) do
    state =
      state
      |> push_layout(layout_id)

    {:ok, state}
  end
end
