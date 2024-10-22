defmodule ReflectOS.Kernel.TestLayout do
  use ReflectOS.Kernel.Layout

  alias ReflectOS.Kernel.Layout.Definition
  alias ReflectOS.Kernel.Option

  embedded_schema do
    field(:spacing, :integer)
  end

  @impl true
  def changeset(%__MODULE__{} = section, params \\ %{}) do
    section
    |> cast(params, [:spacing])
  end

  @impl true
  def layout_definition(),
    do: %Definition{
      name: "Test Layout",
      icon: "test-icon",
      locations: [
        %{key: :top, label: "Top"},
        %{key: :bottom, label: "Bottom"}
      ]
    }

  @impl true
  def layout_options(),
    do: [
      %Option{
        key: :label,
        label: "Label Text"
      }
    ]

  @impl true
  def init_layout(scene, _args, _opts) do
    {:ok, scene}
  end

  @impl true
  def handle_section_update(scene, _tracker, _graph) do
    scene
  end
end
