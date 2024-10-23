defmodule ReflectOS.Kernel.LayoutManagerTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.LayoutManager.State
  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.ActiveLayout
  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore

  import LayoutManager
  doctest LayoutManager

  @table ReflectOS.ActiveLayout
  @key ["active_layout"]

  @current_layout %Layout{
    id: "current-layout-id",
    name: "Test Layout",
    config: %{},
    module: Layout
  }

  @new_layout %Layout{
    id: "new-layout-id",
    name: "Test Layout",
    config: %{},
    module: Layout
  }

  setup_all do
    LayoutStore.save(@current_layout)
    LayoutStore.save(@new_layout)

    on_exit(fn ->
      LayoutStore.delete(@current_layout.id)
      LayoutStore.delete(@new_layout.id)
    end)

    :ok
  end

  setup do
    # Reset state for each test
    PropertyTable.put(@table, @key, nil)
    {:ok, %{}}
  end

  describe "push_layout/0" do
    test "pushes a the new layout" do
      # Arrange
      state = %State{
        layout_id: "current-layout-id"
      }

      new_layout_id = @new_layout.id

      # Act
      result = LayoutManager.push_layout(state, new_layout_id)

      # Assert
      assert result.layout_id == new_layout_id
      assert %{id: ^new_layout_id} = ActiveLayout.get()
    end

    test "doesn't push an invalid layout" do
      # Arrange
      current_layout_id = @current_layout.id
      ActiveLayout.put(current_layout_id)

      state = %State{
        layout_id: current_layout_id
      }

      new_layout_id = 12345

      # Act
      result = LayoutManager.push_layout(state, new_layout_id)

      # Assert
      assert result.layout_id == current_layout_id
      assert %{id: ^current_layout_id} = ActiveLayout.get()
    end

    test "doesn't push an unchanged layout" do
      # Arrange
      current_layout_id = @current_layout.id
      ActiveLayout.put(current_layout_id)

      state = %State{
        layout_id: current_layout_id
      }

      # Act
      result = LayoutManager.push_layout(state, current_layout_id)

      # Assert
      assert result.layout_id == current_layout_id
      assert %{id: ^current_layout_id} = ActiveLayout.get()
    end
  end
end
