defmodule ReflectOS.Kernel.Settings.SectionStoreTest do
  use ExUnit.Case

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.SectionStore

  alias ReflectOS.Kernel.TestSection1

  defp test_section,
    do: %Section{
      id: "test_section_1",
      name: "Test Section",
      module: TestSection1,
      config: %TestSection1{
        label: "Test Label"
      }
    }

  setup do
    on_exit(fn ->
      # Clean up everything we created
      SectionStore.list()
      |> Enum.map(fn %{id: id} -> SectionStore.delete(id) end)
    end)

    :ok
  end

  describe "list/0" do
    test "returns a list of stored sections" do
      # Arrange
      section_1 = test_section()
      section_2 = %{section_1 | id: "section_2"}
      SectionStore.save(section_1)
      SectionStore.save(section_2)

      # Act
      result = SectionStore.list()

      # Assert
      assert [] == result -- [section_1, section_2]
    end
  end

  describe "get/1" do
    test "returns a stored section" do
      # Arrange
      section = test_section()
      SectionStore.save(section)

      # Act/Assert
      assert SectionStore.get(section.id) == section
    end

    test "returns nil when section is not found" do
      assert SectionStore.get("not-found-id") == nil
    end
  end

  describe "save/1" do
    test "saves a section with an id" do
      # Arrange
      section = test_section()

      # Act
      {:ok, result} = SectionStore.save(section)

      # Assert
      assert section == result
    end

    test "saves a section without an id" do
      # Arrange
      section = test_section()
      section = %{section | id: nil}

      # Act
      {:ok, result} = SectionStore.save(section)

      # Assert
      assert result.id != nil
    end

    test "saves a section with map config" do
      # Arrange
      expected = test_section()
      section = %{expected | config: %{}}

      # Assert
      assert {:ok, %Section{} = _} = SectionStore.save(section)
      assert SectionStore.get(section.id) == expected
    end
  end

  describe "subscribe/1" do
    test "notifies caller of changes" do
      # Arrange
      section = test_section()
      SectionStore.save(section)
      SectionStore.subscribe(section.id)

      # Act
      section = %{section | name: "A new name"}
      SectionStore.save(section)

      # Assert
      expected = %{section | config: Map.from_struct(section.config)}

      assert_receive %PropertyTable.Event{
        value: ^expected
      }
    end
  end

  describe "delete/1" do
    test "removes the section" do
      # Arrange
      section = test_section()
      section = %{section | id: "delete-me"}
      SectionStore.save(section)

      # Act
      SectionStore.delete(section.id)

      # Assert
      assert SectionStore.get(section.id) == nil
    end
  end
end
