defmodule ReflectOS.Kernel.Settings.LayoutManagerStoreTest do
  use ExUnit.Case

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.Settings.LayoutManagerStore

  alias ReflectOS.Kernel.TestLayoutManager

  defp test_layout_manager,
    do: %LayoutManager{
      id: "test_layout_manager_1",
      name: "Test Layout Manager",
      module: TestLayoutManager,
      config: %TestLayoutManager{
        layout: "test-layout-id"
      }
    }

  setup do
    on_exit(fn ->
      # Clean up everything we created
      LayoutManagerStore.list()
      |> Enum.map(fn %{id: id} -> LayoutManagerStore.delete(id) end)
    end)

    :ok
  end

  describe "list/0" do
    test "returns a list of stored layout managers" do
      # Arrange
      layout_manager_1 = test_layout_manager()
      layout_manager_2 = %{layout_manager_1 | id: "layout_manager_2"}
      LayoutManagerStore.save(layout_manager_1)
      LayoutManagerStore.save(layout_manager_2)

      # Act
      result = LayoutManagerStore.list()

      # Assert
      assert [] == result -- [layout_manager_1, layout_manager_2]
    end
  end

  describe "get/1" do
    test "returns a stored layout manager" do
      # Arrange
      layout_manager = test_layout_manager()
      LayoutManagerStore.save(layout_manager)

      # Act/Assert
      assert LayoutManagerStore.get(layout_manager.id) == layout_manager
    end

    test "returns nil when layout manager is not found" do
      assert LayoutManagerStore.get("not-found-id") == nil
    end
  end

  describe "save/1" do
    test "saves a layout manager with an id" do
      # Arrange
      layout_manager = test_layout_manager()

      # Act
      {:ok, result} = LayoutManagerStore.save(layout_manager)

      # Assert
      assert layout_manager == result
    end

    test "saves a layout manager without an id" do
      # Arrange
      layout_manager = test_layout_manager()
      layout_manager = %{layout_manager | id: nil}

      # Act
      {:ok, result} = LayoutManagerStore.save(layout_manager)

      # Assert
      assert result.id != nil
    end

    test "saves a layout manager with map config" do
      # Arrange
      expected = test_layout_manager()
      layout_manager = %{expected | config: Map.from_struct(expected.config)}

      # Assert
      assert {:ok, %LayoutManager{} = _} = LayoutManagerStore.save(layout_manager)
      assert LayoutManagerStore.get(layout_manager.id) == expected
    end
  end

  describe "subscribe/1" do
    test "notifies caller of changes" do
      # Arrange
      layout_manager = test_layout_manager()
      LayoutManagerStore.save(layout_manager)
      LayoutManagerStore.subscribe(layout_manager.id)

      # Act
      layout_manager = %{layout_manager | name: "A new name"}
      LayoutManagerStore.save(layout_manager)

      # Assert
      expected = %{layout_manager | config: Map.from_struct(layout_manager.config)}

      assert_receive %PropertyTable.Event{
        value: ^expected
      }
    end
  end

  describe "delete/1" do
    test "removes the layout manager" do
      # Arrange
      layout_manager = test_layout_manager()
      layout_manager = %{layout_manager | id: "delete-me"}
      LayoutManagerStore.save(layout_manager)

      # Act
      LayoutManagerStore.delete(layout_manager.id)

      # Assert
      assert LayoutManagerStore.get(layout_manager.id) == nil
    end
  end
end
