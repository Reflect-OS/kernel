defmodule ReflectOS.Kernel.ActiveLayoutTest do
  use ExUnit.Case
  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore
  alias ReflectOS.Kernel.ActiveLayout

  @table ReflectOS.ActiveLayout
  @key ["active_layout"]

  @test_layout %Layout{
    id: "test_layout_id",
    name: "Test Layout",
    config: %{},
    module: Layout
  }

  setup_all do
    LayoutStore.save(@test_layout)
    on_exit(fn -> LayoutStore.delete(@test_layout.id) end)
    :ok
  end

  setup do
    # Reset state for each test
    PropertyTable.put(@table, @key, nil)
    {:ok, %{}}
  end

  describe "get/0" do
    test "returns nil when there is no active layout" do
      assert ActiveLayout.get() == nil
    end

    test "returns the active layout" do
      # Arrange
      layout_id = @test_layout.id
      PropertyTable.put(@table, @key, layout_id)

      # Act/Assert
      assert %Layout{id: ^layout_id} = ActiveLayout.get()
    end
  end

  describe "put/1" do
    test "stores the active layout id" do
      # Arrange
      layout_id = @test_layout.id
      ActiveLayout.put(layout_id)

      # Act/Assert
      assert %Layout{id: ^layout_id} = ActiveLayout.get()
    end
  end

  describe "subscribe/0" do
    test "notifies caller of changes" do
      # Arrange
      ActiveLayout.subscribe()

      layout_id = @test_layout.id
      ActiveLayout.put(layout_id)

      # Act/Assert
      assert_receive %PropertyTable.Event{
        table: @table,
        property: @key,
        value: ^layout_id
      }
    end
  end
end
