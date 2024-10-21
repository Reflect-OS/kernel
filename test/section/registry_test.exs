defmodule ReflectOS.Kernel.Section.RegistryTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.Section.Registry

  defmodule TestSection1 do
    use ReflectOS.Kernel.Section
    alias ReflectOS.Kernel.Section.Definition
    alias ReflectOS.Kernel.Option

    embedded_schema do
      field(:label, :string)
    end

    @impl true
    def changeset(%TestSection1{} = section, params \\ %{}) do
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
    def init_section(scene, %TestSection1{} = section_config, _opts) do
      {:ok, scene}
    end
  end

  defmodule TestSection2 do
    use ReflectOS.Kernel.Section
    alias ReflectOS.Kernel.Section.Definition
    alias ReflectOS.Kernel.Option

    embedded_schema do
      field(:label, :string)
    end

    @impl true
    def changeset(%TestSection2{} = section, params \\ %{}) do
      section
      |> cast(params, [:label])
    end

    @impl true
    def section_definition(),
      do: %Definition{
        name: "Test Section 2",
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
    def init_section(scene, %TestSection2{} = section_config, _opts) do
      {:ok, scene}
    end
  end

  describe "register/1" do
    test "allows registration with a module" do
      assert Registry.register(TestSection1) == :ok
    end

    test "allows registration with a list of module" do
      assert Registry.register([TestSection1, TestSection2]) == :ok
    end
  end

  describe "definitions/0" do
    test "returns a list of section definitions" do
      # Arrange
      Registry.register([TestSection1, TestSection2])

      expected =
        [
          TestSection1.section_definition(),
          TestSection2.section_definition()
        ]

      # Act / Assert
      assert ^expected = Registry.definitions()
    end
  end

  describe "list/0" do
    test "returns a list of section modules" do
      # Arrange
      Registry.register([TestSection1, TestSection2])

      expected =
        [
          TestSection1,
          TestSection2
        ]

      # Act / Assert
      assert ^expected = Registry.list()
    end
  end
end
