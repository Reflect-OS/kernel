defmodule ReflectOS.Kernel.Settings.LayoutStoreTest do
  use ExUnit.Case

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore

  alias ReflectOS.Kernel.TestLayout

  defp test_layout,
    do: %Layout{
      id: "test_layout_1",
      module: TestLayout,
      config: %TestLayout{
        spacing: 24
      },
      sections: %{
        top: ["top_section_id"],
        bottom: ["bottom_section_id"]
      }
    }

  setup do
    on_exit(fn ->
      # Clean up everything we created
      LayoutStore.list()
      |> Enum.map(fn %{id: id} -> LayoutStore.delete(id) end)
    end)

    :ok
  end

  describe "list/0" do
    test "returns a list of stored layouts" do
      # Arrange
      layout_1 = test_layout()
      layout_2 = %{layout_1 | id: "layout_2"}
      LayoutStore.save(layout_1)
      LayoutStore.save(layout_2)

      # Act
      result = LayoutStore.list()

      # Assert
      assert [] == result -- [layout_1, layout_2]
    end
  end

  describe "get/1" do
    test "returns a stored layout" do
      # Arrange
      layout = test_layout()
      LayoutStore.save(layout)

      # Act/Assert
      assert LayoutStore.get(layout.id) == layout
    end

    test "returns nil when layout is not found" do
      assert LayoutStore.get("not-found-id") == nil
    end
  end

  describe "save/1" do
    test "saves a layout with an id" do
      # Arrange
      layout = test_layout()

      # Act
      {:ok, result} = LayoutStore.save(layout)

      # Assert
      assert layout == result
    end

    test "saves a layout without an id" do
      # Arrange
      layout = test_layout()
      layout = %{layout | id: nil}

      # Act
      {:ok, result} = LayoutStore.save(layout)

      # Assert
      assert result.id != nil
    end

    test "saves a layout with map config" do
      # Arrange
      expected = test_layout()
      layout = %{expected | config: Map.from_struct(expected.config)}

      # Assert
      assert {:ok, %Layout{} = _} = LayoutStore.save(layout)
      assert LayoutStore.get(layout.id) == expected
    end
  end

  describe "subscribe/1" do
    test "notifies caller of changes" do
      # Arrange
      layout = test_layout()
      LayoutStore.save(layout)
      LayoutStore.subscribe(layout.id)

      # Act
      layout = %{layout | name: "A new name"}
      LayoutStore.save(layout)

      # Assert
      expected = %{layout | config: Map.from_struct(layout.config)}

      assert_receive %PropertyTable.Event{
        value: ^expected
      }
    end
  end

  describe "delete/1" do
    test "removes the layout" do
      # Arrange
      layout = test_layout()
      layout = %{layout | id: "delete-me"}
      LayoutStore.save(layout)

      # Act
      LayoutStore.delete(layout.id)

      # Assert
      assert LayoutStore.get(layout.id) == nil
    end
  end
end
