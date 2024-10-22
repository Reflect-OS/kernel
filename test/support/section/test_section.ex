defmodule ReflectOS.Kernel.TestSection do
  use ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Section.Definition
  alias ReflectOS.Kernel.Option

  embedded_schema do
    field(:label, :string)
  end

  @impl true
  def changeset(%__MODULE__{} = section, params \\ %{}) do
    section
    |> cast(params, [:label])
  end

  @impl true
  def section_definition(),
    do: %Definition{
      name: "Test Section 1",
      icon: "test-icon"
    }

  @impl true
  def section_options(),
    do: [
      %Option{
        key: :label,
        label: "Label Text"
      }
    ]

  @impl true
  def init_section(scene, %__MODULE__{} = _section_config, opts) do
    pid = opts[:pid]
    Process.send(pid, {:up, scene}, [])
    {:ok, assign(scene, pid: pid)}
  end
end